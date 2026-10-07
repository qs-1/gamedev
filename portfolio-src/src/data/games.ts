export interface Game {
  number: number;
  title: string;
  description: string;
  href: string;
  tags: string[];
}

export const games: Game[] = [
  {
    number: 5,
    title: "Flappy Bird",
    description: "",
    href: "flappy/index.html",
    tags: ["Arcade", "2D"],
  },
  {
    number: 9,
    title: "3D Ball",
    description: "",
    href: "ball3d/index.html",
    tags: ["3D", "Physics"],
  },
  {
    number: 10,
    title: "Minecraft Lite",
    description: "",
    href: "minecraft/index.html",
    tags: ["3D", "FPS"],
  },
  {
    number: 7,
    title: "Cookie Clicker",
    description: "",
    href: "cookie/index.html",
    tags: ["Idle", "Clicker"],
  }

  {
    number: 10,
    title: "Minelite",
    description: "Assignment 10 game.",
    href: "mine/index.html",
    tags: ["2D"],
  },
];
