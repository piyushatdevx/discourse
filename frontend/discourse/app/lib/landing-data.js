// ==============================================
// FANTRIBE LANDING PAGE STATIC DATA
// ==============================================

// Hero Section Data
export const heroSlides = [
  {
    id: 1,
    image:
      "https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?w=1920&h=1080&fit=crop",
    alt: "Music Studio",
  },
  {
    id: 2,
    image:
      "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=1920&h=1080&fit=crop",
    alt: "Concert Crowd",
  },
  {
    id: 3,
    image:
      "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=1920&h=1080&fit=crop",
    alt: "Band Performance",
  },
  {
    id: 4,
    image:
      "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=1920&h=1080&fit=crop",
    alt: "Festival Stage",
  },
  {
    id: 5,
    image:
      "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=1920&h=1080&fit=crop",
    alt: "DJ Performance",
  },
];

export const heroAvatars = [
  "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop",
  "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop",
  "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop",
];

// Live Right Now Section Data
export const onlineUsers = [
  {
    id: 1,
    name: "Sarah Chen",
    avatar:
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop",
    status: "Browsing synths",
    activity: "Just joined a discussion",
    tribe: "Synth Tribe",
  },
  {
    id: 2,
    name: "Marcus Lee",
    avatar:
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop",
    status: "In live session",
    activity: "Hosting: Design the next synth",
    tribe: "Creator Tools",
  },
  {
    id: 3,
    name: "Aisha Patel",
    avatar:
      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop",
    status: "Active now",
    activity: "Commenting on feedback thread",
    tribe: "Guitar Tribe",
  },
  {
    id: 4,
    name: "Jordan Kim",
    avatar:
      "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=200&h=200&fit=crop",
    status: "Beta testing",
    activity: "Testing new plugin v2.1",
    tribe: "Dev Tribe",
  },
  {
    id: 5,
    name: "Elena Ruiz",
    avatar:
      "https://images.unsplash.com/photo-1598728637989-9c5de7532584?w=200&h=200&fit=crop",
    status: "Creating content",
    activity: "Writing a tutorial",
    tribe: "Vocal Tribe",
  },
  {
    id: 6,
    name: "David Park",
    avatar:
      "https://images.unsplash.com/photo-1759156207851-ff2c0a158797?w=200&h=200&fit=crop",
    status: "Exploring",
    activity: "Browsing community tools",
    tribe: "Sustainability",
  },
];

export const conversations = [
  {
    id: 1,
    channel: "Synth Tribe",
    participants: [
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop",
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop",
      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop",
    ],
    preview:
      "Has anyone tried the new wavetable oscillator? The sound design possibilities are...",
    reactions: ["fire", "thumbsup"],
    isTyping: true,
  },
  {
    id: 2,
    channel: "Guitar Tribe",
    participants: [
      "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=100&h=100&fit=crop",
      "https://images.unsplash.com/photo-1598728637989-9c5de7532584?w=100&h=100&fit=crop",
    ],
    preview:
      "Just finished my first track using the community presets. Absolutely love the...",
    reactions: ["heart", "fire"],
    isTyping: false,
  },
  {
    id: 3,
    channel: "Dev Tribe",
    participants: [
      "https://images.unsplash.com/photo-1759156207851-ff2c0a158797?w=100&h=100&fit=crop",
      "https://images.unsplash.com/photo-1650765814813-ec91a21dec80?w=100&h=100&fit=crop",
    ],
    preview:
      "PR merged! The new MIDI mapping feature is now live. Thanks to everyone who...",
    reactions: ["party", "thumbsup", "heart"],
    isTyping: false,
  },
];

// Tribes Section Data
export const tribes = [
  {
    id: 1,
    name: "Synth Tribe",
    description:
      "Explore sound design, share patches, and shape the future of synthesis together.",
    icon: "music",
    badge: "Fan-Led",
    badgeColor: "primary",
    memberCount: 12500,
    leader: {
      name: "Alex Rivera",
      avatar:
        "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=100&h=100&fit=crop",
    },
    gradient: "from-purple-500 to-indigo-600",
  },
  {
    id: 2,
    name: "Guitar Tribe",
    description:
      "From acoustic to electric, share your riffs and connect with fellow guitarists.",
    icon: "guitar",
    badge: "Active",
    badgeColor: "success",
    memberCount: 8750,
    leader: {
      name: "Maria Santos",
      avatar:
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop",
    },
    gradient: "from-amber-500 to-orange-600",
  },
  {
    id: 3,
    name: "Creator Tools",
    description:
      "Build plugins, share templates, and co-create the tools that power music production.",
    icon: "wrench",
    badge: "Beta Access",
    badgeColor: "warning",
    memberCount: 6200,
    leader: {
      name: "Jordan Kim",
      avatar:
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop",
    },
    gradient: "from-blue-500 to-cyan-600",
  },
  {
    id: 4,
    name: "Vocal Tribe",
    description:
      "Singers, voice actors, and vocal enthusiasts sharing techniques and collaborating.",
    icon: "microphone",
    badge: "New",
    badgeColor: "primary",
    memberCount: 4300,
    leader: {
      name: "Elena Ruiz",
      avatar:
        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop",
    },
    gradient: "from-pink-500 to-rose-600",
  },
  {
    id: 5,
    name: "Dev Tribe",
    description:
      "Open-source enthusiasts building the next generation of audio software together.",
    icon: "code",
    badge: "Open Source",
    badgeColor: "success",
    memberCount: 3800,
    leader: {
      name: "David Park",
      avatar:
        "https://images.unsplash.com/photo-1598728637989-9c5de7532584?w=100&h=100&fit=crop",
    },
    gradient: "from-green-500 to-emerald-600",
  },
  {
    id: 6,
    name: "Sustainability",
    description:
      "Eco-conscious creators discussing sustainable practices in music production.",
    icon: "leaf",
    badge: "Growing",
    badgeColor: "success",
    memberCount: 2100,
    leader: {
      name: "Aisha Patel",
      avatar:
        "https://images.unsplash.com/photo-1759156207851-ff2c0a158797?w=100&h=100&fit=crop",
    },
    gradient: "from-teal-500 to-green-600",
  },
];

// Live Sessions Data
export const liveSessions = [
  {
    id: 1,
    title: "Design the next synth",
    host: {
      name: "Alex Rivera",
      image:
        "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=100&h=100&fit=crop",
      role: "Product Lead",
    },
    fans: [
      "https://images.unsplash.com/photo-1598728637989-9c5de7532584?w=100&h=100&fit=crop",
      "https://images.unsplash.com/photo-1759156207851-ff2c0a158797?w=100&h=100&fit=crop",
      "https://images.unsplash.com/photo-1650765814813-ec91a21dec80?w=100&h=100&fit=crop",
    ],
    viewerCount: 1240,
    tags: ["Synth Tribe", "Co-Creation"],
    status: "live",
  },
  {
    id: 2,
    title: "Fan feedback jam session",
    host: {
      name: "Sarah Chen",
      image:
        "https://images.unsplash.com/photo-1650765814813-ec91a21dec80?w=100&h=100&fit=crop",
      role: "Community Mgr",
    },
    fans: [
      "https://images.unsplash.com/photo-1759156207851-ff2c0a158797?w=100&h=100&fit=crop",
      "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=100&h=100&fit=crop",
    ],
    viewerCount: 856,
    tags: ["Open Mic", "Live"],
    status: "live",
  },
];

export const upcomingSessions = [
  {
    id: 3,
    title: "Vocal Chain Masterclass",
    host: {
      name: "Mike Ross",
      image:
        "https://images.unsplash.com/photo-1598728637989-9c5de7532584?w=100&h=100&fit=crop",
    },
    time: "Starts in 45m",
    date: "Today, 4:00 PM",
    status: "soon",
  },
  {
    id: 4,
    title: "Future of MIDI 2.0",
    host: {
      name: "Jessica Wu",
      image:
        "https://images.unsplash.com/photo-1759156207851-ff2c0a158797?w=100&h=100&fit=crop",
    },
    time: "Tomorrow",
    date: "Dec 5, 10:00 AM",
    status: "upcoming",
  },
  {
    id: 5,
    title: "Beta Testing: Loop Station",
    host: {
      name: "David Park",
      image:
        "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=100&h=100&fit=crop",
    },
    time: "Full Capacity",
    date: "Dec 6, 2:00 PM",
    status: "full",
  },
];

// Real Stories Data
export const emotionalStories = [
  {
    id: 1,
    name: "Jamie Chen",
    location: "Seattle, WA",
    avatar:
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop",
    story:
      "I spent years making music alone in my bedroom, convinced nobody would care. Got my first audio interface and finally had the guts to record something. Then I joined MT Fanverse. Sarah heard my first demo and messaged me at 2am saying it made her cry. We've been collaborating ever since. I'm not alone anymore.",
    emotion: "teary",
    impact: "Found my first collaborator",
    memberSince: "3 months ago",
  },
  {
    id: 2,
    name: "Maria Rodriguez",
    location: "Austin, TX",
    avatar:
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop",
    story:
      "As a woman in audio engineering, I always felt like I had to prove myself. Here? People just... listen. My feedback on the new compressor plugin actually made it into the final product. I cried when I saw my name in the credits. I matter here.",
    emotion: "purple_heart",
    impact: "Changed a real product",
    memberSince: "8 months ago",
  },
  {
    id: 3,
    name: "Kwame Osei",
    location: "Lagos, Nigeria",
    avatar:
      "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=200&h=200&fit=crop",
    story:
      "Internet is expensive here. I can't afford most DAWs. The Dev Tribe built a lightweight plugin JUST for creators in low-bandwidth areas. They asked ME what I needed. First time I've ever felt seen by a tech company.",
    emotion: "pray",
    impact: "Got tools that actually work for him",
    memberSince: "5 months ago",
  },
  {
    id: 4,
    name: "Alex Kim",
    location: "Toronto, Canada",
    avatar:
      "https://images.unsplash.com/photo-1598728637989-9c5de7532584?w=200&h=200&fit=crop",
    story:
      "Depression made me stop creating for 2 years. Joined a live session on a whim. Marcus said 'Hey Alex, glad you're here.' That's it. Five words. But they were real. Bought a cheap interface the next day and started recording again. Sometimes all you need is someone to notice you exist.",
    emotion: "heart",
    impact: "Found his spark again",
    memberSince: "2 months ago",
  },
  {
    id: 5,
    name: "Sophia Martinez",
    location: "Barcelona, Spain",
    avatar:
      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop",
    story:
      "My daughter asked why I never pursued music. Didn't have an answer. Found this community, shared my first track at 43 years old. The support was overwhelming. Now she sees me creating every weekend. Teaching her it's never too late to chase dreams.",
    emotion: "sparkles",
    impact: "Inspiring the next generation",
    memberSince: "6 months ago",
  },
  {
    id: 6,
    name: "Jordan Taylor",
    location: "London, UK",
    avatar:
      "https://images.unsplash.com/photo-1519626551145-832f0aa4a368?w=200&h=200&fit=crop",
    story:
      "Non-binary creator. Constantly misgendered on other platforms. Here, people just... get it. My pronouns are respected. My voice is heard. I can just be myself and make music. That shouldn't be revolutionary, but it feels like it.",
    emotion: "rainbow",
    impact: "Found acceptance",
    memberSince: "4 months ago",
  },
];

export const creatorTestimonials = [
  {
    name: "Marcus Chen",
    role: "Bedroom Producer",
    image:
      "https://images.unsplash.com/photo-1760780567530-389d8a3fba75?w=400&h=300&fit=crop",
    quote:
      "MT Fanverse gave me the confidence to share my unfinished tracks. Now I'm collaborating with artists I've admired for years. It's not just a platform; it's a family.",
    tags: ["First-Time Creator", "Electronic"],
  },
  {
    name: "Elena Rodriguez",
    role: "Touring DJ",
    image:
      "https://images.unsplash.com/photo-1763630051876-928346788268?w=400&h=300&fit=crop",
    quote:
      "Connecting with fans on a personal level has changed how I perform. I see the faces from the Tribe in the crowd and it fuels my energy.",
    tags: ["Professional", "Live"],
  },
  {
    name: "David Okonjo",
    role: "Music Educator",
    image:
      "https://images.unsplash.com/photo-1691333940510-7286846c5342?w=400&h=300&fit=crop",
    quote:
      "The educational resources and community support here are unmatched. My students are finding their unique sounds faster than ever.",
    tags: ["Mentor", "Community Leader"],
  },
];

export const quickTestimonials = [
  {
    name: "Sarah Johnson",
    role: "Music Enthusiast",
    content:
      "FanHub has completely transformed how I connect with other fans. The community is amazing and I've made friends from all over the world!",
    rating: 5,
    avatar:
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop",
  },
  {
    name: "Michael Chen",
    role: "Sports Fan",
    content:
      "The real-time updates and chat features are incredible. I never miss a moment and can share the excitement with fellow fans instantly.",
    rating: 5,
    avatar:
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop",
  },
  {
    name: "Emma Davis",
    role: "Community Leader",
    content:
      "Building my own community on FanHub was so easy. The tools are intuitive and the engagement has been phenomenal!",
    rating: 5,
    avatar:
      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop",
  },
];

// Your Adventure Data
export const journeySteps = [
  {
    id: 1,
    title: "Discover",
    icon: "search",
    description: "Find new artists and hidden gems in your favorite genres.",
    action: "Explore Communities",
    active: false,
  },
  {
    id: 2,
    title: "Engage",
    icon: "message-square",
    description:
      "Join discussions, share stories, and connect with like-minded fans.",
    action: "Join a Conversation",
    active: true,
  },
  {
    id: 3,
    title: "Co-Create",
    icon: "pen-tool",
    description:
      "Collaborate directly with creators on new music, merch, and ideas.",
    action: "Jump In Now",
    active: false,
  },
  {
    id: 4,
    title: "Earn Recognition",
    icon: "award",
    description: "Gain badges and status as a top contributor in your tribe.",
    action: "See Rewards",
    active: false,
  },
  {
    id: 5,
    title: "Lead the Tribe",
    icon: "crown",
    description:
      "Become a community leader and guide the future of the fanverse.",
    action: "Leadership Path",
    active: false,
  },
];

export const missions = [
  {
    id: 1,
    title: "Share Your Riff",
    description:
      "Record a 30s video of your latest riff or beat and tag #MTFanverse.",
    difficulty: "Medium",
    time: "15 min",
    reward: "50 Points",
    icon: "share2",
    participants: [
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop",
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop",
      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop",
    ],
    participantCount: 127,
  },
  {
    id: 2,
    title: "Vote on Next Feature",
    description:
      "Help us decide which synth engine to build next in our roadmap poll.",
    difficulty: "Easy",
    time: "2 min",
    reward: "10 Points",
    icon: "mouse-pointer-click",
    participants: [
      "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=100&h=100&fit=crop",
      "https://images.unsplash.com/photo-1519626551145-832f0aa4a368?w=100&h=100&fit=crop",
    ],
    participantCount: 342,
  },
  {
    id: 3,
    title: "Test Prototype V2",
    description:
      "Download the beta plugin and submit a bug report or feedback.",
    difficulty: "Hard",
    time: "45 min",
    reward: "Early Access Badge",
    icon: "message-square",
    participants: [
      "https://images.unsplash.com/photo-1598728637989-9c5de7532584?w=100&h=100&fit=crop",
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop",
    ],
    participantCount: 54,
  },
  {
    id: 4,
    title: "Host Local Meetup",
    description: "Organize a small gathering of music makers in your city.",
    difficulty: "Hard",
    time: "2 hours",
    reward: "Merch Pack",
    icon: "map-pin",
    participants: [
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop",
    ],
    participantCount: 18,
  },
];

export const userBadges = [
  { name: "First Feedback", icon: "chat", color: "light" },
  { name: "Trendsetter", icon: "fire", color: "coral" },
  { name: "Beta Tester", icon: "tool", color: "gray" },
];

// Community Resources Data
export const tools = [
  {
    id: 1,
    title: "AI-Assisted Presets",
    description:
      "Smart mastering chains that adapt to your sound while preserving your unique human touch.",
    icon: "sliders",
    badge: "Popular",
    type: "Download",
    creator: {
      name: "Marcus Chen",
      role: "Audio Engineer",
      avatar:
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop",
    },
  },
  {
    id: 2,
    title: "Collab Templates",
    description:
      "Standardized DAW project files designed to make remote co-creation seamless and agile.",
    icon: "layout-template",
    badge: "Essential",
    type: "Template",
    creator: {
      name: "Dev Tribe Collective",
      role: "Community Contributors",
      avatar:
        "https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=100&h=100&fit=crop",
    },
  },
  {
    id: 3,
    title: "The Hybrid Guide",
    description:
      "A handbook on balancing algorithmic growth with authentic, community-driven connection.",
    icon: "book-open",
    badge: "New",
    type: "Knowledge",
    creator: {
      name: "Sarah Mitchell",
      role: "Community Strategist",
      avatar:
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop",
    },
  },
  {
    id: 4,
    title: "Community Plugins",
    description:
      "Open-source VSTs and tools built by fellow tribe members to solve real creative hurdles.",
    icon: "users",
    badge: "Open Source",
    type: "Software",
    creator: {
      name: "Dev Tribe Collective",
      role: "52 Contributors",
      avatar:
        "https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=100&h=100&fit=crop",
    },
  },
  {
    id: 5,
    title: "Eco-Touring Kit",
    description:
      "Resources and checklists for planning sustainable, low-impact live shows and tours.",
    icon: "cpu",
    badge: "Sustainability",
    type: "Guide",
    creator: {
      name: "Alex Rivera",
      role: "Sustainable Tour Manager",
      avatar:
        "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=100&h=100&fit=crop",
    },
  },
];

export const topContributors = [
  {
    id: 1,
    name: "Maya Rodriguez",
    role: "Community Champion",
    avatar:
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop",
    contributions: 247,
    impact: "Led 12 co-creation sessions",
    badge: "Top Contributor",
    gradient: "from-red-500 to-coral-500",
  },
  {
    id: 2,
    name: "Jordan Kim",
    role: "Beta Tester",
    avatar:
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop",
    contributions: 189,
    impact: "Tested 23 new features",
    badge: "Early Adopter",
    gradient: "from-charcoal-900 to-charcoal-600",
  },
  {
    id: 3,
    name: "Sophia Chen",
    role: "Content Creator",
    avatar:
      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop",
    contributions: 156,
    impact: "Created 8 tutorials",
    badge: "Creator",
    gradient: "from-amber-500 to-coral-500",
  },
];

export const recentStories = [
  {
    id: 1,
    name: "Alex T.",
    avatar:
      "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=100&h=100&fit=crop",
    story:
      "Just finished my first collaboration with the Synth Tribe! Never thought my feedback would make it into the final product. This community is incredible!",
    timestamp: "2 hours ago",
    likes: 42,
  },
  {
    id: 2,
    name: "Priya M.",
    avatar:
      "https://images.unsplash.com/photo-1519626551145-832f0aa4a368?w=100&h=100&fit=crop",
    story:
      "The live session today with Sarah was amazing. Love how our ideas are actually being heard and implemented. This is what real co-creation looks like!",
    timestamp: "5 hours ago",
    likes: 67,
  },
  {
    id: 3,
    name: "Carlos D.",
    avatar:
      "https://images.unsplash.com/photo-1598728637989-9c5de7532584?w=100&h=100&fit=crop",
    story:
      "Earned my first 500 points! The gamification here is fun, but what really keeps me coming back is the genuine connections I've made.",
    timestamp: "1 day ago",
    likes: 38,
  },
];

// Footer Data
export const footerLinks = {
  product: [
    { label: "Discover", href: "#" },
    { label: "Co-Create", href: "#" },
    { label: "Fan Missions", href: "#" },
    { label: "Stories", href: "#" },
  ],
  company: [
    { label: "About Us", href: "#" },
    { label: "Careers", href: "#" },
    { label: "Blog", href: "#" },
    { label: "Contact", href: "#" },
  ],
  legal: [
    { label: "Privacy Policy", href: "#" },
    { label: "Terms of Service", href: "#" },
    { label: "Cookie Policy", href: "#" },
    { label: "Guidelines", href: "#" },
  ],
};

export const socialLinks = [
  { name: "Facebook", icon: "facebook", href: "#" },
  { name: "Twitter", icon: "twitter", href: "#" },
  { name: "Instagram", icon: "instagram", href: "#" },
  { name: "YouTube", icon: "youtube", href: "#" },
];
