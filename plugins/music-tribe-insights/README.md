# Music Tribe Insights

Community Insights (report types / recurring themes) for the Music Tribe forum, powered by **AWS Bedrock**. When many users post about the same issue (e.g. a specific guitar problem), admins see it as a "report type" in the admin panel.

---

## Where to see Community Insights

### Admin dashboard (run analysis and refresh)

- **URL:** `https://YOUR-DISCOURSE-SITE/admin/dashboard/community_insights`  
  (Local dev: `http://localhost:4200/admin/dashboard/community_insights`)
- **Or:** Admin → Dashboard → **Community Insights** tab.

Use this page to **refresh** insights (run the Bedrock analysis job). The tab is visible only to **admins**. Do **not** use `/u/admin/dashboard/...` (that path does not exist).

### User profile tab (view insights with chart)

When logged in as an **admin**, a **Community Insights** tab appears in the **user profile nav** (next to Summary, Activity, Notifications, etc.). It links to:

- **URL:** `https://YOUR-DISCOURSE-SITE/u/YOUR_USERNAME/activity/community-insights`  
  (e.g. `http://localhost:4200/u/admin/activity/community-insights`)

This page shows the same insights in a **dedicated layout** with a **red-themed bar chart** (report types and post counts). Data is read-only here; use Admin → Community Insights to run a refresh.

---

## Settings and how your posts become insights

These settings (Admin → Settings → search for “music_tribe” or “Community Insights”) control **which posts** are analyzed and **how** the AI groups them.

### Music tribe insights days to analyze

- **What it is:** Number of days of history we look at.
- **How it works:** Only posts **created in the last N days** are considered. Default **30**, range 7–90.
- **Example:** If set to 30, only posts from the last 30 days are eligible. Older posts are ignored.

### Music tribe insights max posts

- **What it is:** Maximum number of posts we send to the AI in one run.
- **How it works:** From the posts in the “days” window (above), we take the **most recent** posts, up to this limit. Default **500**, range 50–2000.
- **Example:** If you have 1000 posts in the last 30 days, only the **500 most recent** are sent to Bedrock. The other 500 are not analyzed in that run.

### Music tribe insights min posts per theme

- **What it is:** The minimum number of **topics** we ask the AI to require before reporting a theme (K in the prompt) for the AI to report it as a “theme.”
- **How it works:** We tell the AI: “Only report a theme if at least **K** topics clearly relate to it” (K = this setting). Default **3**, range 2–20. We do **not** filter by this number on the server after the AI responds—we only drop themes with 0 topics. You may still see themes with 1 or 2 topics.
- **Example:** If set to 3, the AI is told to prefer themes with at least 3 topics (e.g. “Guitar M1 issue” with 5 topics). It may still return themes with 1–2 topics; those are shown too.

### If I have 1000 posts, do all of them appear in Community Insights?

**No.** There is a clear pipeline:

1. **Eligible:** Only the **opening post** of each topic from the last **days to analyze** (e.g. 30 days), that are regular, non-deleted, non-hidden, in default topics.
2. **Sent to the AI:** At most **max posts** (e.g. 500) **topics** (one opening post per topic). Replies are not sent. So 1000 topics in the window → at most 500 sent.
3. **What comes back:** The AI returns **themes** (report types), not a list of every post. Each theme has:
   - a label (e.g. “Guitar M1 issue”),
   - a summary,
   - a **count** of topics,
   - and the **post IDs** that belong to that theme.
4. **What you see in the UI:** Only posts that the AI **grouped into a recurring theme** appear under “Related posts” for each theme. So you see a small set of themes, and each theme shows only the posts the AI assigned to it — not all 500 (or 1000) posts.

So: **not every post is shown.** Only posts that the AI clusters into at least one theme are listed, and only up to **max posts** are analyzed in the first place.

### Why did I see the same topic many times? (posts vs topics)

Only the opening post of each topic is analyzed (replies are ignored). So one **topic** (e.g. "Musictribe community") has one row in the **topics** table but many rows in **posts** (the first post plus every reply). The AI groups **posts** into themes, so a theme can contain 12 **posts** from the same topic — that’s why you saw "Musictribe community" 12 times (12 posts in one topic).

The UI now shows **Related topics** instead of listing every post: one link per topic with the post count (e.g. **"Musictribe community (12 posts)"**). Each link goes to the topic URL `/t/slug/topic_id`, so you open the topic once and see all posts/replies there. The chart count (e.g. 12) is still the number of **posts** the AI grouped into that theme; the list shows unique **topics** so the same topic is not repeated.

---

## How "Refresh insights" works (end-to-end)

When you click **Refresh insights**, this is the exact flow: what runs, what is sent to the AI, what is stored, and where the screen gets its data.

### 1. Click "Refresh insights"

- **Frontend** (admin or user activity page): the `refresh` action runs.
- It sends **POST** to `/admin/community_insights/refresh.json`.
- **Backend** (`MusicTribeInsights::AdminController#refresh`): enqueues a background job and returns `{ success: true }`.
- **Frontend**: shows an alert ("Community insights refresh has been queued…") and starts **polling** **GET** `/admin/dashboard/community_insights.json` every 5 seconds until `generated_at` is present (or timeout).

### 2. Background job (Sidekiq)

- Job class: `Jobs::MusicTribeInsightsGenerateInsights`.
- It calls `MusicTribeInsights::BedrockAnalyzer.call` (only if `music_tribe_insights_enabled` is on).

### 3. What is sent to the AI (BedrockAnalyzer)

**Step A – Fetch data (from your database)**

- **Code:** `fetch_posts_for_analysis` in `app/services/music_tribe_insights/bedrock_analyzer.rb`.
- **Query:** We take one row **per topic** (so we analyze topics, not every reply). We fetch only the **opening post** (post_number = 1) of each topic: public, non-deleted, regular, default topics, from the last **N** days, ordered by newest first, limited to **M** topics (setting `music_tribe_insights_max_posts`).
- **Per topic we currently send:** `post_id` (opening post id), `topic_id`, `topic_title`, and an **excerpt of the opening post body only** (first 400 chars). So the AI sees **topic title + first post content only**; it does not see replies/comments for that topic.

**Why “only opening post” in the data source?**  
We still want **one row per topic** (so the AI groups by topic and we don’t count one topic with 20 replies as 20 items). The current implementation sends each topic with **title + first post excerpt only**. So the AI has less context than the full thread. To give the AI **each topic with title + that topic’s full content/excerpt** (opening post + all replies combined or concatenated), the fetch and prompt could be extended so that per topic we send title + a combined excerpt of all posts in that topic; that would let the AI understand the thread in depth while still analyzing by topic. Right now we do not do that—we only send the first post content per topic.
- If there are **no topics**, the job stores an empty result and stops (no API call).

**Step B – Build the prompt**

- **Code:** `build_prompt(posts_data)`.
- The prompt includes:
  - Instructions: find recurring themes / report types; only report a theme if **at least K posts** relate to it (K = `music_tribe_insights_min_posts_per_theme`).
  - Required JSON shape: `{"report_types": [{"type": "...", "summary": "...", "count": N, "post_ids": [1,2,3]}, ...]}`.
  - The list of posts: each line like `[1] (post_id=123 topic_id=456) Topic: ... \nContent: <excerpt>`.

**Step C – Call AWS Bedrock**

- **Code:** `invoke_bedrock(prompt)`.
- **Sent to AI:** That single text prompt (posts + instructions).
- **API:** `Aws::BedrockRuntime::Client#invoke_model` with the configured region and model (e.g. Claude 3 Haiku).
- **Response:** The model returns a JSON body; we take the first content block’s **text** (the model’s reply). If that text is blank, we treat it as `{"report_types":[]}`.

### 4. What the AI returns and how we use it

- The model is asked to return **JSON only**, e.g.  
  `{"report_types": [{"type": "Guitar X issue", "summary": "...", "count": 5, "post_ids": [10,20,30,40,50]}, ...]}`.
- **Code:** `parse_response(response_json, posts_data)`:
  - Parses the JSON and reads `report_types` (array).
  - Keeps at most 20 report types.
  - For each type, we take `post_ids` and **keep only IDs that were in the analyzed set** (the posts we actually sent). The **count** we store is the length of this filtered list (so it’s consistent with the posts we sent).
  - If the JSON is invalid, we use an empty array.

### 5. Where the result is stored

- **Code:** `store_result(report_types, posts_analyzed)` or `store_empty(posts_analyzed)`.
- **Storage:** **PluginStore** (Discourse’s key-value store for plugins).
  - **Key:** plugin name `"music-tribe-insights"`, store key `"community_insights"`.
  - **Value:**  
    `report_types`, `generated_at` (ISO8601), `posts_analyzed`, `days_analyzed`, `max_posts`.
- So: **the screen never talks to the AI.** It only reads this stored blob.

**What is PluginStore?**  
PluginStore is Discourse’s key-value store for plugin data. It is not a normal database table; it’s a dedicated store (backed by the database) where plugins can save and read blobs by plugin name and key. Other plugins use it for settings, cache, or state. Our plugin uses it to cache the last Bedrock result so every page load or poll reads from there instead of calling the AI again.

**How long is data stored in PluginStore?**  
There is **no automatic expiry**. The data we write under `"community_insights"` stays there until it is **overwritten** the next time you click **Refresh insights** and the job runs successfully, or until the key is removed (e.g. plugin uninstall or manual cleanup). So the “last run” result persists until the next refresh.

**Refresh: manual or automatic?**  
Refresh is **manual only**. There is **no scheduler** and **no automatic refresh**. You must click **Refresh insights** when you want a new analysis. On every visit (or when you open the Community Insights page later), the app simply **reads from PluginStore** and shows whatever was last stored—it does **not** call Bedrock again. So if you want updated insights (e.g. after new topics are created), you have to click **Refresh insights** again.

### 6. Where the screen gets its data

- **Request:** **GET** `/admin/dashboard/community_insights.json` (on load and when polling after refresh).
- **Backend:** `MusicTribeInsights::AdminController#index`:
  - Reads **PluginStore** for `"community_insights"`.
  - **Enriches** each report type’s `post_ids` with post details (e.g. topic title) from the DB, and only includes non-deleted posts.
  - Returns JSON: `report_types`, `generated_at`, `posts_analyzed`, `days_analyzed`, `max_posts`.
- **Frontend:** Uses that JSON to render the chart, the “Related posts” links, and the “Based on N posts…” line.

### 7. Why you see "No recurring themes met the threshold in recent posts"

That message is shown when:

- **`generated_at` is present** (so the job ran and stored something), and  
- **`report_types` is empty** (no themes to show).

So the AI either returned no themes, or we ended up with no valid themes after processing. Common reasons:

1. **Threshold (min posts per theme)**  
   The prompt says: “Only report a theme if at least **K** topics clearly relate to it” (K = **Music tribe insights min posts per theme** in Admin → Settings). If there aren’t enough posts, or no theme has ≥ K posts, the model may return `report_types: []`.  
   **Try:** Lower **Music tribe insights min posts per theme** (e.g. to 2) and run **Refresh insights** again.

2. **Not enough posts in the window**  
   We only send posts from the last **N** days, up to **M** posts (Settings). If the forum has very few such posts, the AI has little to group.  
   **Try:** Increase **Music tribe insights days to analyze** or **Music tribe insights max posts**, then refresh.

3. **Model returned empty or invalid JSON**  
   If the model returns no text, or JSON that doesn’t have `report_types`, or invalid JSON, we treat it as no themes.  
   **Check:** Rails/Sidekiq logs for errors; optionally enable **Model invocation logging** in Bedrock to see the exact request/response in CloudWatch.

4. **Themes with zero posts dropped**  
   We only drop report types that end up with 0 posts (e.g. invalid post IDs from the AI). Themes with 1+ posts are kept; the prompt asks the AI for at least min posts per theme in the prompt, but we don't filter by that on the server, so you still see “No recurring themes”.

5. **AI non-determinism**  
   The model uses a non-zero temperature, so it can sometimes return themes and sometimes return none for the same data. If you see “No recurring themes” once and then get data after another **Refresh insights**, that’s expected. You can run refresh again to get a new result.

**Summary table**

| Step | Where | What happens |
|------|--------|----------------|
| Click Refresh | Frontend | POST `/admin/community_insights/refresh` → job enqueued; then poll GET `/admin/dashboard/community_insights` |
| Job runs | Sidekiq | `BedrockAnalyzer.call` |
| Data to AI | `fetch_posts_for_analysis` | Posts from DB (last N days, up to M, non-deleted, default topics) |
| Prompt to AI | `build_prompt` | Instructions + “min K posts per theme” + list of posts (id, topic, excerpt) |
| AI call | `invoke_bedrock` | Single request to Bedrock with that prompt |
| AI response | Model output | JSON string `{"report_types": [...]}` |
| After AI | `parse_response` | Parse JSON, filter post_ids to analyzed set, set count = filtered length; themes with 0 posts are dropped |
| Storage | `store_result` / `store_empty` | **PluginStore** key `"community_insights"` (report_types, generated_at, …) |
| Screen load | GET index | **PluginStore.get** → enrich with titles → JSON to frontend |

---

## Enabling the feature

1. **Enable the plugin**  
   Admin → **Plugins** → find **music-tribe-insights** → enable.

2. **Restart Sidekiq**  
   After enabling the plugin, restart Sidekiq (e.g. stop and run `bundle exec sidekiq` again). Otherwise you may see `uninitialized constant Jobs::MusicTribeInsightsGenerateInsights` in the Sidekiq Dead tab, because Sidekiq only loads plugins at boot.

3. **Enable the setting**  
   Admin → **Settings** → search for `music_tribe_insights` or **Community Insights** → turn **on** `music_tribe_insights_enabled`.

4. **Configure AWS Bedrock** (see below), then use **Refresh insights** on the Community Insights page.

---

## Configuring AWS for Bedrock

The plugin uses the **AWS SDK for Ruby** and the **default credential chain**. You do **not** put AWS keys in the admin UI—the region and model in Settings only choose *which* Bedrock region/model to use; **credentials are configured outside Discourse**.

### Where to set credentials

| Environment | Where to configure |
|-------------|--------------------|
| **Local dev** (e.g. `bin/rails s`) | Create a **`.env`** file in the project root (see repo root `.env.example`) with `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_REGION`. Rails loads `.env` automatically in development. |
| **Production (single server)** | In your process manager (systemd, upstart) or in the shell that starts Discourse, or in a `.env` loaded by your app. |
| **Docker** | In `app.yml` env section or in the container’s environment. |
| **EC2 / ECS / Lambda** | Use an IAM role with Bedrock permissions (no access keys needed). |

### Option A: Environment variables (recommended for single server)

Set these **on the machine/container where Discourse (Rails) runs**—not in the browser or in Admin → Settings:

```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_REGION="us-east-1"
```

- **Region:** Use the same region where Bedrock is available (e.g. `us-east-1`, `us-west-2`). You can override the region in **Admin → Settings** with `music_tribe_insights_aws_region`.
- **Access key:** Use an IAM user (or role) that has permission to call Bedrock.

### Option B: IAM role (recommended for EC2/ECS/Lambda)

If Discourse runs on **EC2**, **ECS**, or **Lambda**, attach an IAM role that has Bedrock permissions. Do **not** set `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`; the SDK will use the role. You can still set `AWS_REGION` or use the site setting.

### IAM permissions

The user or role must be allowed to call Bedrock. Example policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel"
      ],
      "Resource": "arn:aws:bedrock:REGION::foundation-model/anthropic.claude-3-haiku-*"
    }
  ]
}
```

Replace `REGION` with your region (e.g. `us-east-1`). For other Claude models, adjust the `Resource` ARN to match the model ID you use in the setting `music_tribe_insights_model_id`.

### Enable Bedrock in the AWS account

1. In the **AWS Console**, open **Amazon Bedrock** (in the region you use).
2. In the left menu, go to **Model access** (or **Foundation models**).
3. **Request access** for the model you use (e.g. **Claude 3 Haiku** by Anthropic).
4. Wait until access is **Granted** before using "Refresh insights".

### Verifying where the data comes from

- **Source is your Discourse database.** The plugin reads public, non-deleted **regular** posts in **default** topics (same as normal forum topics), from the last N days, up to M posts (see Settings). That list is sent to AWS Bedrock; the AI returns theme labels and which post IDs it grouped into each theme. The **“Posts”** count for each row is the number of those post IDs that were actually in the analyzed set (so it’s verifiable and not made up by the AI).
- **In the UI:** The data source line says “Based on N posts from the last K days… from your Discourse database.” A second line explains that theme labels and counts come from AI analysis of that set.
- **In code:** See `fetch_posts_for_analysis` in `app/services/music_tribe_insights/bedrock_analyzer.rb` for the exact query.

### How to see what we sent to the AI and what the AI returned

**1. In your Rails / Sidekiq logs (easiest)**  
Each time the insights job runs, the plugin logs the request and response. Look for:

- `[MusicTribeInsights] Request sent to AI` — prompt length and first 2500 chars of the prompt we send to Bedrock.
- `[MusicTribeInsights] Response from AI` — the exact JSON string the model returned.

Run Sidekiq in a terminal and click **Refresh insights**; these lines appear there. Or tail your Rails/Sidekiq log and grep for `MusicTribeInsights`.

**2. In AWS Bedrock (CloudWatch)**  
In **Bedrock → Settings**, enable **Model invocation logging** and choose a CloudWatch log group. Every Bedrock call is then logged there with full request and response. In **CloudWatch** (same region) → **Log groups** → that log group to view invocations.

### Seeing AI usage and history in AWS Bedrock

The Bedrock console left menu (Discover, Infer, Build, etc.) does not show a dedicated “Usage” item. Use one of these:

1. **Settings**  
   In the left sidebar, open **Configure and learn → Settings**. Check for **Usage**, **Billing**, or **CloudWatch** logging. Some accounts see usage or links to cost there.

2. **AWS Billing / Cost Explorer**  
   - Go to **AWS Billing** (search “Billing” in the top bar) → **Bills** or **Cost Explorer**.  
   - Filter by **Service: Amazon Bedrock** and by **Region** (e.g. ap-south-1) and **Time range**.  
   - You’ll see cost and (in Cost Explorer) usage over time for Bedrock API calls.

3. **CloudWatch (metrics)**  
   - Go to **CloudWatch** in the same region (ap-south-1).  
   - **Metrics → All metrics** (or **Browse**).  
   - Look for a **Bedrock** namespace or **By Service Name → Bedrock**.  
   - Open metrics such as **Invocations**, **InputTokenCount**, **OutputTokenCount** and set the time range to see history.

4. **Request-level history (invocation logs)**  
   In Bedrock: **Configure and learn → Settings**. Under **Model invocation logging**, turn it **On**. When prompted, choose or create a **CloudWatch log group** for the region. After that, every Bedrock call (including from this plugin) will publish metadata, requests, and responses to that log group. To view history: **CloudWatch** (same region) → **Log groups** → select the Bedrock log group → **Log streams** or **Search log group** to see when each invocation happened.

### Summary

| What              | Where |
|-------------------|--------|
| **Page URL**      | `/admin/dashboard/community_insights` |
| **Enable feature**| Admin → Settings → `music_tribe_insights_enabled` = on |
| **AWS credentials** | Server environment: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` (or IAM role) |
| **AWS region**    | Env `AWS_REGION` or setting `music_tribe_insights_aws_region` |
| **Model**         | Setting `music_tribe_insights_model_id` (default: Claude 3 Haiku) |
