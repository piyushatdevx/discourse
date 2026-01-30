# FanTribe - Figma Design Prompts by Module

## Design System Foundation

### Brand Colors
- **Primary Red (Logo/Buttons):** #FF1844 / #FF1744
- **Dark/Text:** #1A1A1A
- **Button Text:** #FFFFFF

### Design Philosophy
- Clean, minimal social-style interface
- Glassmorphism effects (frosted glass, blur, transparency)
- Soft shadows and subtle gradients
- Rounded corners (8-16px radius)
- Ample white space
- Outfit google fonts - typography (Inter, SF Pro, or similar)

---

## Module 1: Landing Page & Onboarding

### Figma Prompt:

**Design a modern social platform landing page and complete onboarding flow for "FanTribe" - a community-based social network.**

**Page 1: Public Landing Page (FR-LND-01)**

Create a hero section with:
- Large bold tagline centered or left-aligned
- Subtle glassmorphism card effect behind the hero text
- Primary CTA button in #FF1744 with white text, rounded corners (12px), subtle shadow
- Secondary ghost button with #1A1A1A border
- Abstract gradient background with soft red (#FF1844) to dark (#1A1A1A) transition
- Floating glassmorphic elements for visual interest

Featured Tribes Section:
- 6 tribe cards in a 3x2 grid (desktop) or 2-column (tablet) or single column (mobile)
- Each card: glassmorphic background (rgba(255,255,255,0.1)), blur effect, 1px white/10% border
- Card contents: tribe avatar (rounded), tribe name, member count badge, brief description
- Hover state: subtle lift with increased blur/glow

Social Proof Section:
- Testimonial cards with glassmorphism effect
- User avatar, quote, name, tribe affiliation
- Animated counter for platform stats (users, tribes, posts)

Navigation:
- Sticky header with frosted glass effect (backdrop-blur)
- Logo on left, nav links center, Login/Sign Up buttons right
- Sign Up button: filled #FF1744, Login: ghost/outline style

Footer:
- Dark background (#1A1A1A)
- Links: Terms, Privacy Policy, Contact, Social icons
- Clean grid layout

**Page 2: Email Registration (FR-LND-02)**

Design a centered registration modal/page:
- Glassmorphic card container (max-width 420px)
- Frosted glass background with soft shadow
- Form fields with:
  - Floating labels or placeholder text
  - Subtle border (1px rgba(26,26,26,0.1))
  - Focus state: #FF1744 border glow
  - Real-time validation icons (checkmark green, X red)
  - Password strength indicator bar
- Show/hide password toggle icon
- Primary submit button full-width #FF1744
- Divider with "or continue with"
- Social OAuth buttons row
- Link to login for existing users
- Error states: red border, error message below field

**Page 3: Email Verification Pending**
- Centered illustration (envelope/email icon)
- Glassmorphic card with instructions
- Resend email button (secondary style)
- Timer countdown for resend availability

**Page 4: Social OAuth (FR-LND-03)**

Design OAuth buttons:
- Google button: white background, Google logo, "Continue with Google"
- Facebook button: Facebook blue (#1877F2), Facebook logo, "Continue with Facebook"
- Both buttons: rounded corners, subtle shadow, full-width in auth forms
- Loading state with spinner
- Error state modal for OAuth failures

**Page 5: Login (FR-LND-04)**

Design login form:
- Same glassmorphic card style as registration
- Email and password fields
- "Remember me" checkbox with custom styled checkmark
- "Forgot password?" link aligned right
- Login button full-width #FF1744
- Social login options below divider
- Link to registration

**Page 6: Password Reset Flow (FR-LND-05)**

Screen 1 - Request Reset:
- Simple glassmorphic card
- Email input field
- Submit button
- Back to login link

Screen 2 - Check Email:
- Success illustration
- Instructions text
- Resend option

Screen 3 - New Password:
- Password field with requirements checklist
- Confirm password field
- Submit button

**Page 7: Language Selector (FR-LND-06)**

Design language selector component:
- Dropdown in header/footer
- Globe icon + current language
- Dropdown with glassmorphism effect
- Language options with flag icons
- Checkmark on selected language

**Responsive Breakpoints:**
- Desktop: 1440px, 1920px
- Tablet: 768px, 1024px
- Mobile: 375px, 390px

---

## Module 2: User Profiles

### Figma Prompt:

**Design a complete user profile system for FanTribe with social-style layouts and glassmorphism effects.**

**Page 1: Profile Creation Wizard (FR-PRF-01)**

Design a multi-step onboarding wizard:
- Progress indicator at top (steps: Username → Display Name → Avatar → Bio)
- Step 1 - Username:
  - Input field with @ prefix
  - Real-time availability check (loading spinner, green check, red X)
  - Username suggestions chips below field
  - Character counter and rules displayed
  
- Step 2 - Display Name:
  - Simple text input
  - Character counter (2-50)
  
- Step 3 - Avatar Upload:
  - Large circular upload zone (dashed border, drag-drop area)
  - Upload button alternative
  - Image cropper modal with circular mask
  - Preview of uploaded image
  - Default avatar preview (initials-based, gradient background)
  
- Step 4 - Bio:
  - Textarea with character counter (300 max)
  - Optional fields: Location (with icon), Website URL
  
Navigation:
- Skip link (subtle, top right)
- Back button (ghost style)
- Continue/Finish button (#FF1744)

All in glassmorphic card container with soft shadows.

**Page 2: Profile Display - Own Profile (FR-PRF-02)**

Design social-style profile page:

Cover Photo Area:
- Full-width banner (16:9 or 3:1 aspect ratio)
- Gradient overlay at bottom for text readability
- Edit cover button (camera icon, glassmorphic)

Profile Header:
- Large avatar (120-150px) overlapping cover photo
- Avatar border: white 4px, subtle shadow
- Edit avatar button overlay on hover
- Display name (large, bold)
- @username (gray, smaller)
- Bio text below
- Location and website with icons (if provided)

Stats Row:
- Glassmorphic card/bar
- Posts count | Followers count | Following count
- Each clickable to view lists

Action Buttons (for own profile):
- Edit Profile button (primary #FF1744)

Tabs Section:
- Posts | Tribes | About
- Underline indicator for active tab
- Smooth tab switching

Activity Feed:
- User's posts in card format
- Infinite scroll
- Empty state if no posts

**Page 3: Profile Display - Other User (FR-PRF-02)**

Same layout as own profile with different actions:
- Follow/Following button (toggle state)
- Message button (secondary style)
- More options (•••) menu: Block, Report, Copy link

Following states:
- "Follow" - outlined button
- "Following" - filled #FF1744, on hover shows "Unfollow"

**Page 4: Profile Editing (FR-PRF-03)**

Design inline edit mode and full edit modal:

Inline Edit:
- Pencil icons next to editable fields
- Click to reveal input, save/cancel buttons

Full Edit Modal/Page:
- Glassmorphic modal (large)
- All profile fields editable
- Avatar upload with change option
- Cover photo upload
- Username with 30-day change warning
- Unsaved changes indicator
- Cancel and Save Changes buttons

**Page 5: Privacy Settings (FR-PRF-04)**

Design settings page/section:
- Clean list of privacy options
- Each setting row:
  - Setting name and description
  - Toggle switch or dropdown selector
  
Settings to design:
- Profile Visibility: Radio/dropdown (Public, Followers Only, Private)
- Activity Feed Visibility: Same options
- Tribe Memberships: Toggle (Public/Hidden)
- Online Status: Toggle
- Who Can DM: Dropdown (Everyone, Followers, No one)
- Search Engine Indexing: Toggle

Use glassmorphic cards to group related settings.

**Page 6: Blocked/Private Profile States (Edge Cases)**

- Private profile view (for non-followers): Lock icon, limited info, "Request to Follow" button
- Blocked user view: Minimal info, "You are blocked" message
- Deleted user placeholder: Ghost avatar, "[Deleted User]" text

**Components to Create:**
- Avatar component (multiple sizes: 24, 32, 48, 64, 120px)
- Profile card (compact version for hovers/mentions)
- Stats badge
- Follow button states
- Privacy toggle row

---

## Module 3: Feed & Content

### Figma Prompt:

**Design a complete social feed system for FanTribe with post creation, display, and engagement features using glassmorphism and the brand color palette.**

**Page 1: Post Composer (FR-FED-01)**

Design the post creation experience:

Collapsed State (in feed):
- Glassmorphic card
- User avatar on left
- "What's happening?" placeholder input
- Quick action icons: Image, Audio, Hashtag

Expanded Composer Modal:
- Larger glassmorphic modal
- User avatar and name top-left
- Rich text area (auto-expanding)
- Character counter (5000 max) - changes color near limit
- Media attachment row:
  - Image upload button with count badge (max 4)
  - Audio upload button
- Image preview grid (2x2 for 4 images, proper spacing)
- Audio preview player component
- Tribe selector dropdown (optional, "Post to...")
- Hashtag suggestions dropdown (auto-complete on #)
- Mention suggestions dropdown (auto-complete on @)
- Bottom bar: Cancel (ghost) | Post button (#FF1744)

Draft indicator: "Draft saved" with timestamp

**Page 2: Main Feed (FR-FED-02, FR-FED-03)**

Design the personalized feed:

Feed Header:
- "Home" title or tab navigation (For You | Following)
- New posts indicator pill ("12 new posts" - click to load)
- Pull-to-refresh indicator for mobile

Post Card Design:
- Glassmorphic card with subtle border
- Header row: Avatar | Name + @username + timestamp | More menu (•••)
- Content area:
  - Text with proper line height
  - Hashtags styled in #FF1744
  - @mentions styled as links
  - "See more" for truncated long posts
- Media area:
  - Single image: full width, rounded corners
  - Multiple images: 2x2 grid with rounded corners
  - Audio player: waveform visualization, play button, duration
- Engagement bar:
  - Like button (heart icon, filled when liked with #FF1744)
  - Comment button (bubble icon) with count
  - Repost button (arrows icon) with count
  - Share button (arrow/send icon)
- All icons: subtle gray, active state in #FF1744

Like Animation: Heart fills with scale animation, particles burst

**Page 3: Single Post View (FR-FED-03)**

Design expanded post view:
- Post card (same as feed but no truncation)
- Engagement stats: "X likes" "X reposts" (clickable to see users)
- Divider
- Comment composer (avatar + input + post button)
- Comments section (threaded)

**Page 4: Comments (FR-FED-05)**

Design comment thread:
- Comment card: Avatar | Name + username + timestamp | Content
- Nested replies with indent (up to 3 levels)
- "Show X replies" collapse/expand
- Reply button on each comment
- Like button on comments (smaller)
- More menu: Edit, Delete, Report

Comment Composer:
- Inline below post
- Avatar + input field + Post button
- Replying to @username indicator when replying to specific comment

**Page 5: Post Actions (FR-FED-06, FR-FED-07, FR-FED-08)**

Edit Post:
- Same as composer, pre-filled
- "Editing" indicator
- Save Changes button

Delete Post:
- Confirmation modal
- Glassmorphic warning card
- Post preview inside modal
- Cancel | Delete buttons (Delete in red)

Repost Options:
- Repost (instant, shows in your profile)
- Quote Repost (opens composer with embedded original post)
- Copy Link
- Share to... (external options)

**Page 6: Hashtags & Mentions (FR-FED-09)**

Hashtag Page:
- Header: #hashtag name, post count
- Feed of posts with this hashtag
- Trending hashtags sidebar

Autocomplete Dropdown:
- Glassmorphic dropdown
- Search results list
- Hashtag: #name + post count
- Mention: Avatar + name + @username

**Page 7: Media Posts (FR-FED-10, FR-FED-11)**

Image Gallery Lightbox:
- Full-screen overlay (dark)
- Image centered
- Navigation arrows
- Close button
- Image counter (1/4)
- Swipe support indicator for mobile

Audio Player Component:
- Glassmorphic player bar
- Play/pause button (large)
- Waveform or progress bar
- Current time / Duration
- Volume control (desktop)
- Download option (if allowed)

**Page 8: Feed Empty/Loading States**

Empty Feed:
- Illustration
- "Welcome! Follow people or join tribes to fill your feed"
- Suggested users/tribes cards

Loading State:
- Skeleton loaders matching post card structure
- Subtle shimmer animation

**Components to Create:**
- Post card (multiple variants)
- Engagement button group
- Media grid layouts (1, 2, 3, 4 images)
- Audio player
- Comment component
- Skeleton loaders
- Compose button (FAB for mobile)

---

## Module 4: Tribes (Groups)

### Figma Prompt:

**Design a complete Tribes (community groups) system for FanTribe with creation, management, and discovery features using glassmorphism effects.**

**Page 1: Create Tribe (FR-TRB-01)**

Design tribe creation flow:

Step 1 - Basic Info:
- Glassmorphic modal/page
- Tribe name input (with uniqueness check)
- Description textarea (500 chars)
- Category dropdown (Sports, Music, Gaming, Entertainment, etc.)

Step 2 - Visuals:
- Icon upload (circular, similar to avatar)
- Banner upload (wide, 16:9 or 3:1)
- Preview of how it will look

Step 3 - Privacy & Settings:
- Privacy level radio buttons with descriptions:
  - Public: "Anyone can see and join"
  - Private: "Anyone can see, approval required to join"
  - Hidden: "Only members can see, invite only"
- Rules/guidelines textarea

Step 4 - Review:
- Preview of tribe page
- Create Tribe button (#FF1744)

**Page 2: Tribe Page (FR-TRB-02)**

Design the main tribe page:

Header Section:
- Full-width banner with gradient overlay
- Tribe icon (large, overlapping banner)
- Tribe name (large, bold)
- Member count + "members" label
- Privacy badge (Public/Private)
- Description text (truncated with "more")

Action Bar:
- Join button (for non-members) - #FF1744
- Leave button (for members) - ghost/outline
- Notification bell (dropdown: All, Mentions, None)
- Share button
- More options (Report, Mute)

For admins/owners:
- Admin Panel button

Tab Navigation:
- Feed | Members | About | (Admin - if applicable)

**Page 3: Tribe Feed (FR-TRB-06)**

Design tribe-specific feed:
- Pinned posts section (yellow/gold pin icon, slightly different card style)
- Regular posts (same card design as main feed)
- "Create post" composer (tribe auto-selected)
- Filter chips: All | Popular | Media | Recent
- Empty state: "Be the first to post in this tribe!"

**Page 4: Members List (FR-TRB-03, FR-TRB-04)**

Design members tab:
- Search members input
- Filter by role: All | Owners | Admins | Moderators
- Member cards:
  - Avatar + Name + @username
  - Role badge (color-coded)
  - Join date
  - For admins: More menu (Promote, Demote, Remove, Ban)

Role Badges:
- Owner: Gold/yellow
- Admin: Purple
- Moderator: Blue
- Member: No badge or subtle gray

**Page 5: About Tab**

Design about section:
- Full description
- Rules section (numbered list or cards)
- Category tag
- Created date
- Statistics: Total posts, Active members this week

**Page 6: Join Flow (FR-TRB-03)**

Public Tribe:
- Join button → immediate join → button changes to "Joined ✓"

Private Tribe:
- "Request to Join" button
- Pending state: "Request Pending" (disabled, gray)
- Modal for admin to approve: User card + Approve/Deny buttons

Invite Flow:
- Invite modal: Search users, select, send invite
- Notification received by invitee
- Accept/Decline buttons in notification

**Page 7: Tribe Admin Panel (FR-TRB-08)**

Design admin dashboard:

Sidebar Navigation:
- Overview
- Edit Tribe Info
- Member Management
- Join Requests
- Moderation Queue
- Roles & Permissions
- Analytics
- Danger Zone

Overview Tab:
- Quick stats cards (members, posts, growth)
- Recent activity
- Pending items badges

Edit Tribe Info:
- Form similar to creation (all fields editable)
- Save Changes button

Member Management:
- Full member list with bulk actions
- Search and filter
- Individual member actions (promote, remove, ban)

Join Requests (for private tribes):
- Request cards with user info
- Approve | Deny buttons
- Bulk approve/deny

Roles & Permissions (FR-TRB-07):
- Permission matrix table
- Checkboxes for each permission per role
- Custom role creation (optional)

**Page 8: Tribe Discovery (FR-TRB-09)**

Design explore/discover page:

Header:
- "Discover Tribes" title
- Search bar (large, prominent)

Filters:
- Category pills (All, Sports, Music, Gaming, etc.)
- Sort dropdown (Popular, New, Active)

Results Grid:
- Tribe cards in grid layout (3-4 per row desktop)
- Card: Banner, Icon, Name, Description preview, Member count, Join button

Sections:
- Trending Tribes (horizontal scroll)
- Recommended for You
- New Tribes
- Browse by Category

Empty Search:
- "No tribes found" message
- "Create your own tribe" CTA

**Page 9: Tribe Notifications (FR-TRB-10)**

Design notification preferences:
- Per-tribe notification settings (in tribe settings or bell dropdown)
- Options: All Activity | Mentions Only | Announcements Only | Muted
- Push notification toggle per tribe

**Page 10: Tribe Analytics (FR-TRB-11)**

Design analytics dashboard for admins:
- Date range picker
- Charts:
  - Member growth line chart
  - Post activity bar chart
  - Engagement rate trend
- Top contributors list
- Member activity breakdown (pie chart: Active, Lurkers, Inactive)
- Export button (CSV)

**Components to Create:**
- Tribe card (grid view)
- Tribe card (list view)
- Member row component
- Role badge
- Permission checkbox row
- Analytics chart cards
- Join request card

---

## Module 5: Chat / Messaging

### Figma Prompt:

**Design a complete direct messaging system for FanTribe with modern chat UI, glassmorphism effects, and real-time features.**

**Page 1: Messages Access & Inbox (FR-CHT-01, FR-CHT-02)**

Design the messaging hub:

Desktop Layout (Split View):
- Left panel (320px): Conversation list
- Right panel: Active conversation

Mobile Layout:
- Full-screen conversation list
- Full-screen conversation view (separate)

Conversation List:
- Header: "Messages" title + New message button (compose icon)
- Search conversations input
- Conversation rows:
  - Avatar (with online indicator dot)
  - Name + @username
  - Last message preview (truncated, gray)
  - Timestamp (relative: 2m, 1h, Yesterday)
  - Unread badge (red dot or count)
- Active conversation: highlighted background

Empty State:
- Illustration
- "No messages yet"
- "Start a conversation" button

**Page 2: Conversation Thread (FR-CHT-03)**

Design the chat view:

Header:
- Back arrow (mobile)
- Recipient avatar + name + online status
- More options (•••): Mute, Block, Delete conversation

Messages Area:
- Messages grouped by date ("Today", "Yesterday", date)
- Received messages: Left-aligned, light glassmorphic bubble
- Sent messages: Right-aligned, #FF1744 background, white text
- Message bubble contents: Text, timestamp (small, below)
- Avatar shown for received messages

Media in Messages:
- Images: Rounded, clickable to expand
- Files: Attachment card with icon, filename, size, download button

Read Receipts:
- Double checkmark icon below sent messages
- "Read" indicator

Typing Indicator:
- Animated dots (...) in a bubble
- "[Name] is typing..."

**Page 3: Message Input (FR-CHT-04)**

Design input area:
- Glassmorphic input bar at bottom
- Attachment button (paperclip/+) - opens options
- Text input (auto-grow)
- Emoji button (opens picker)
- Send button (#FF1744, arrow icon)

Attachment Options (FR-CHT-07):
- Modal/popover with options: Photo, File
- Upload progress bar
- Preview before sending

Emoji Picker:
- Glassmorphic popover
- Category tabs
- Search emojis
- Recent emojis row
- Skin tone selector

**Page 4: New Message (FR-CHT-02)**

Design compose new message:
- Modal or new view
- "To:" field with user search
- User search results dropdown (avatar + name + username)
- Selected users as chips/tags
- Message input area
- Send button

**Page 5: Message Actions (FR-CHT-05)**

Design message context menu:
- Long-press (mobile) or right-click (desktop)
- Glassmorphic popover
- Options: Copy, Edit (own messages), Delete, Reply

Edit Message:
- Inline edit mode
- Input replaces message bubble
- Save/Cancel buttons
- "Edited" indicator on edited messages

Delete Message:
- Confirmation modal
- "Delete for everyone" option
- Deleted message placeholder: "This message was deleted"

**Page 6: Chat Notifications (FR-CHT-08)**

Design notification states:
- In-app toast notification (avatar + name + message preview)
- Push notification preview (device mockup)
- Unread badge on messages nav icon
- Mute conversation toggle (bell icon in conversation header)

**Page 7: Online Status (FR-CHT-09)**

Design status indicators:
- Online: Green dot (bottom-right of avatar)
- Offline: No dot or gray dot
- Away: Yellow dot (optional)

Last Active:
- "Active now"
- "Active 5m ago"
- "Active yesterday"

Privacy:
- "This user has hidden their online status" (if applicable)

**Page 8: Block Flow (FR-CHT-10)**

Design blocking:
- Block option in more menu
- Confirmation modal: "Block [Username]?"
- Blocked state: Conversation hidden
- Blocked user attempting to message: "You cannot message this user"

Blocked Users List (in settings):
- List of blocked users
- Unblock button per user

**Components to Create:**
- Conversation list item
- Message bubble (sent/received variants)
- Media message
- File attachment card
- Typing indicator
- Read receipt icons
- Online status dot
- New message composer
- Emoji picker

---

## Module 6: Notifications

### Figma Prompt:

**Design a comprehensive notification system for FanTribe including notification center, badges, toast notifications, and push notification previews.**

**Page 1: Notification Center (FR-NOT-01, FR-NOT-02)**

Design the notification dropdown/page:

Header Trigger:
- Bell icon in main navigation
- Unread badge (red circle, number or dot)

Dropdown Design:
- Glassmorphic dropdown panel (350px wide)
- Header: "Notifications" + "Mark all as read" link
- Tabs: All | Mentions | Follows (optional)
- Notification list (scrollable)

Notification Item Design:
- Icon (based on type) - left side
- Avatar of related user
- Notification text: "[User] liked your post" (with bold user name)
- Content preview (if applicable)
- Timestamp (relative)
- Unread indicator (blue dot or highlighted background)
- Click action: Navigate to relevant content

Notification Types (FR-NOT-01) - Icons:
- Like: Heart icon (#FF1744)
- Comment: Message bubble icon
- Mention: @ symbol icon
- Follow: User+ icon
- Tribe invite: Group icon
- Tribe approval: Checkmark icon
- DM received: Envelope icon
- Repost: Arrows icon

Grouped Notifications:
- "5 people liked your post" (multiple avatars stacked)
- Expandable to see all users

Footer:
- "See all notifications" link

**Page 2: Full Notification Page**

Design full notifications page:
- Same list design as dropdown
- Filter sidebar: All, Likes, Comments, Mentions, Follows, Tribes
- Infinite scroll
- Empty state per filter

**Page 3: Unread Badge (FR-NOT-03)**

Design badge component:
- Red circle (#FF1744)
- White text number
- Minimum size: 18px height
- Position: Top-right of icon, slight overlap
- Max display: "99+"
- Animation: Subtle scale on count change

Badge variants:
- Dot only (no number)
- Number badge
- Large number (99+)

**Page 4: In-App Toast (FR-NOT-04)**

Design toast notification:
- Glassmorphic toast container
- Position: Top-right (desktop), Top-center (mobile)
- Contents: Icon + Avatar + Text + Timestamp
- Close (X) button
- Click to navigate
- Auto-dismiss: Progress bar at bottom (5s countdown)
- Stack behavior: Up to 3 visible, newest on top

Toast variants:
- Standard notification
- Success message (green accent)
- Error message (red accent)
- Warning message (yellow accent)

**Page 5: Push Notification Preview (FR-NOT-05)**

Design device mockups:
- iOS notification preview (lock screen style)
- Android notification preview
- Desktop notification (browser/OS style)

Push content:
- App icon
- "FanTribe" title
- Notification text
- Timestamp
- Action buttons (Reply, Like - where applicable)

**Page 6: Notification Preferences (FR-NOT-06)**

Design settings page:

Section: Notification Channels
- In-app notifications: Toggle (always on)
- Push notifications: Toggle
- Email notifications: Toggle

Section: Notification Types (Matrix)
Table format:
| Type | In-App | Push | Email |
| Likes | ✓ | ✓ | - |
| Comments | ✓ | ✓ | ✓ |
| Mentions | ✓ | ✓ | ✓ |
| Follows | ✓ | ✓ | - |
| DMs | ✓ | ✓ | ✓ |
| Tribe activity | ✓ | ✓ | Digest |

Each cell: Checkbox or toggle

Section: Quiet Hours
- Enable toggle
- Start time picker
- End time picker

Section: Per-Tribe Settings
- List of joined tribes
- Each: Dropdown (All, Mentions, None)

**Page 7: Empty & Edge States**

Empty Notifications:
- Illustration
- "No notifications yet"
- "When someone interacts with you, you'll see it here"

Notification for Deleted Content:
- Grayed out item
- "[Content no longer available]"

**Components to Create:**
- Notification item (multiple types)
- Unread badge
- Toast notification
- Notification icon with badge
- Toggle row for settings
- Time picker

---

## Module 7: Admin & Moderation

### Figma Prompt:

**Design a comprehensive admin panel and moderation system for FanTribe with dashboard, user management, content moderation, and analytics features.**

**Page 1: Admin Login & Access (FR-ADM-01)**

Design secure admin entry:
- Admin login page (separate from main login)
- 2FA verification screen
- Code input (6 digits, auto-advance)
- Backup code option

Admin Navigation:
- Separate admin layout
- Dark sidebar navigation (professional feel)
- Logo at top
- Navigation items with icons:
  - Dashboard
  - Users
  - Content
  - Tribes
  - Reports
  - Announcements
  - Analytics
  - Settings
  - Audit Log
- User info at bottom (admin avatar + name + logout)

**Page 2: Dashboard Overview (FR-ADM-02)**

Design the admin dashboard:

Quick Stats Cards (top row):
- Total Users (with % change)
- Active Today (DAU)
- New Users (today)
- Pending Reports (red highlight if > 0)
- Posts Created (today)
- Active Tribes

Charts Section:
- User Growth (line chart, last 30 days)
- Daily Active Users (bar chart, last 7 days)
- Content Volume (posts/comments stacked area)

Quick Actions:
- View Reports Queue
- Create Announcement
- Manage Users

Recent Activity Feed:
- Latest signups, reports, admin actions
- Compact list format

System Health:
- Status indicators (green/yellow/red)
- API, Database, Storage, Email

**Page 3: Content Reporting (FR-ADM-03)**

Design user-facing report flow:
- Report button (flag icon) on posts, comments, profiles
- Report modal:
  - "Report this [content type]" header
  - Radio buttons for reasons (Spam, Harassment, Hate Speech, Violence, Misinformation, Copyright, Other)
  - Additional details textarea (optional)
  - Submit button
- Confirmation: "Thanks for reporting. We'll review this shortly."

**Page 4: Report Review Queue (FR-ADM-04)**

Design moderation queue:

List View:
- Filter tabs: All | Pending | In Review | Resolved
- Sort: Newest, Oldest, Most Reports
- Bulk select checkboxes
- Bulk actions: Approve All, Remove All

Report Card:
- Report ID + Timestamp
- Reported content preview (text, image thumbnail)
- Report reason badge (color-coded)
- Reporter info (avatar + name)
- Number of reports (if multiple)
- Content author info
- Action buttons: View, Approve, Remove, Warn Author, Ban Author

Expanded Review View:
- Full content display
- All reports listed (multiple reporters)
- User history (past reports/actions)
- Moderator notes input
- Action dropdown: No Action | Remove Content | Warn User | Suspend User | Ban User
- Resolution reason textarea
- Submit button

**Page 5: User Management (FR-ADM-05)**

Design user management:

User List:
- Search bar (by username, email, ID)
- Filters: Status (Active, Suspended, Banned), Role, Join Date
- User rows:
  - Avatar + Name + @username + Email
  - Status badge
  - Role badge
  - Joined date
  - Actions: View, Edit, Suspend, Ban

User Detail View:
- Full profile info
- Account status card
- Activity stats
- Recent posts list
- Reports (received and made)
- Admin action history
- Action buttons:
  - Edit Profile
  - Reset Password
  - Change Role
  - Suspend (with duration picker and reason)
  - Ban (with reason)
  - Delete Account

Suspension Modal:
- Duration dropdown: 1 day, 7 days, 30 days, Custom
- Reason textarea
- Notify user checkbox
- Confirm button

**Page 6: Announcements (FR-ADM-06)**

Design announcement system:

Announcement List:
- All announcements (active, scheduled, expired)
- Status badges
- Create new button

Create Announcement:
- Title input
- Rich text content editor
- Priority level: Info (blue), Warning (yellow), Critical (red)
- Target audience: All Users, Specific Tribes (multi-select)
- Display options:
  - Banner (top of site)
  - Modal (on login)
- Dismissible toggle
- Schedule: Start date/time, End date/time
- Preview button
- Publish / Save Draft buttons

Announcement Banner Preview:
- Top of page, full width
- Color based on priority
- Close (X) button if dismissible

**Page 7: Audit Logs (FR-ADM-07)**

Design audit log viewer:
- Date range picker
- Filter by: Action type, Admin user, Target user
- Search input

Log Table:
- Timestamp
- Admin user (avatar + name)
- Action (badge: User Suspended, Content Removed, etc.)
- Target (user or content)
- Details (expandable)
- IP address

Log Detail Modal:
- All action metadata
- Before/after state (if applicable)
- Related items

Export button: CSV download

**Page 8: Analytics Dashboard (FR-ADM-08)**

Design comprehensive analytics:

Overview Tab:
- Key metrics cards with sparklines
- Comparison to previous period

Users Tab:
- Signups over time (line chart)
- Active users (DAU/WAU/MAU line chart)
- Retention cohort chart
- User demographics (pie charts)
- Top users table

Content Tab:
- Posts created over time
- Engagement rates (likes, comments per post)
- Top posts table
- Content type breakdown

Tribes Tab:
- New tribes over time
- Active tribes ranking
- Member distribution

Traffic Tab:
- Sessions over time
- Traffic sources (pie chart)
- Device breakdown
- Geographic distribution (map)

All charts:
- Date range picker
- Granularity toggle (day, week, month)
- Export options

**Page 9: Admin Settings**

Design platform settings:

General Settings:
- Platform name
- Logo upload
- Primary color picker
- Feature toggles

User Settings:
- Registration options
- Password requirements
- Username rules
- Default privacy settings

Content Settings:
- Post character limit
- Media upload limits
- Comment settings
- Hashtag settings

Moderation Settings:
- Auto-moderation rules
- Word filter configuration
- Report thresholds

Email Settings:
- Email templates
- Notification settings

**Components to Create:**
- Admin sidebar navigation
- Stats card
- Data table with sorting/filtering
- User row with actions
- Report card
- Announcement editor
- Chart components
- Status badges (role, account status, report status)
- Action confirmation modals

---

## Global Components Library

### Figma Prompt:

**Create a comprehensive component library for FanTribe with all reusable UI elements using the glassmorphism design system.**

**Core UI Components:**

Buttons:
- Primary (#FF1744, white text)
- Secondary (ghost, #1A1A1A border)
- Tertiary (text only)
- Danger (red variant)
- States: Default, Hover, Active, Disabled, Loading
- Sizes: Small, Medium, Large

Inputs:
- Text input
- Textarea (auto-grow)
- Search input with icon
- Password input with toggle
- States: Default, Focus, Error, Disabled
- With/without labels
- With/without helper text

Form Elements:
- Checkbox (custom styled)
- Radio button
- Toggle switch
- Dropdown/Select
- Multi-select with tags
- Date picker
- Time picker
- File upload zone

Cards:
- Base card (glassmorphism)
- Post card
- User card (compact, full)
- Tribe card (grid, list)
- Notification card
- Stats card

Navigation:
- Top navbar (glassmorphism)
- Sidebar navigation
- Tab bar
- Breadcrumbs
- Pagination

Overlays:
- Modal (small, medium, large)
- Drawer (side panel)
- Dropdown menu
- Popover
- Tooltip

Feedback:
- Toast notifications
- Alert banners
- Progress bar
- Loading spinner
- Skeleton loaders

Media:
- Avatar (all sizes, with status dot)
- Image (single, gallery grid)
- Video player controls
- Audio player
- File attachment card

Typography:
- Headings (H1-H6)
- Body text (Large, Regular, Small)
- Caption text
- Links
- Code/monospace

Icons:
- Navigation icons
- Action icons
- Status icons
- Social icons

**Design Tokens:**

Colors:
- Primary: #FF1744, #FF1844
- Dark: #1A1A1A
- Gray scale: 50, 100, 200, 300, 400, 500, 600, 700, 800, 900
- Success: Green
- Warning: Yellow/Amber
- Error: Red
- Info: Blue

Glassmorphism Styles:
- Glass Light: rgba(255,255,255,0.1), blur 10px
- Glass Medium: rgba(255,255,255,0.15), blur 20px
- Glass Dark: rgba(26,26,26,0.5), blur 20px
- Border: 1px solid rgba(255,255,255,0.1)

Shadows:
- Small: 0 2px 8px rgba(0,0,0,0.1)
- Medium: 0 4px 16px rgba(0,0,0,0.12)
- Large: 0 8px 32px rgba(0,0,0,0.15)

Spacing:
- 4px increments (4, 8, 12, 16, 24, 32, 48, 64)

Border Radius:
- Small: 4px
- Medium: 8px
- Large: 12px
- XL: 16px
- Full: 9999px (pills, avatars)

Typography Scale:
- Display: 48px
- H1: 36px
- H2: 30px
- H3: 24px
- H4: 20px
- H5: 18px
- H6: 16px
- Body: 16px
- Small: 14px
- Caption: 12px

---

## Responsive Breakpoints & Layouts

**Breakpoints:**
- Mobile S: 320px
- Mobile M: 375px
- Mobile L: 425px
- Tablet: 768px
- Laptop: 1024px
- Desktop: 1440px
- Desktop L: 1920px

**Layout Grids:**
- Mobile: 4 columns, 16px gutter, 16px margin
- Tablet: 8 columns, 24px gutter, 32px margin
- Desktop: 12 columns, 24px gutter, auto margin (max-width 1200px content)

---

*End of FanTribe Figma Design Prompts*
