export interface Game {
  number: number;
  title: string;
  description: string;
  href: string;
  tags: string[];
}

export const games: Game[] = [
  {
    number: 1,
    title: "Wanderer",
    description: "Top-down exploration with smooth tile-based movement.",
    href: "wanderer/index.html",
    tags: ["Top-down", "2D"],
  },
  {
    number: 2,
    title: "Ricochet",
    description: "Bounce projectiles off walls to hit targets.",
    href: "ricochet/index.html",
    tags: ["Physics", "2D"],
  },
  {
    number: 3,
    title: "Fruit Frenzy",
    description: "Catch falling fruit before it hits the ground.",
    href: "fruit/index.html",
    tags: ["Arcade", "2D"],
  },
  {
    number: 4,
    title: "Ping Pong",
    description: "Classic two-paddle pong with velocity-based physics.",
    href: "pong/index.html",
    tags: ["Classic", "2D"],
  },
  {
    number: 5,
    title: "Flappy Bird",
    description: "Navigate through gaps - simple input, brutal difficulty.",
    href: "flappy/index.html",
    tags: ["Arcade", "2D"],
  },
  {
    number: 6,
    title: "Breakout",
    description: "Destroy all bricks with a bouncing ball and paddle.",
    href: "breakout/index.html",
    tags: ["Classic", "2D"],
  },
  {
    number: 7,
    title: "Cookie Clicker",
    description: "Idle clicking game with upgrades and passive income.",
    href: "cookie/index.html",
    tags: ["Idle", "Clicker"],
  },
  {
    number: 8,
    title: "Pop a Balloon",
    description: "Pop balloons as fast as you can before time runs out.",
    href: "balloon/index.html",
    tags: ["Arcade", "2D"],
  },
  {
    number: 9,
    title: "3D Ball",
    description: "Roll a ball through a 3D environment - first foray into 3D.",
    href: "ball3d/index.html",
    tags: ["3D", "Physics"],
  },
  {
    number: 10,
    title: "Minecraft Lite",
    description: "First-person exploration - a Minecraft-inspired 3D world.",
    href: "minecraft/index.html",
    tags: ["3D", "FPS"],
  },
];
