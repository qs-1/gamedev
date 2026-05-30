import { ExternalLink, Gamepad2, GitBranch } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { games } from "@/data/games";

function GameCard({ game }: { game: (typeof games)[number] }) {
  return (
    <Card className="flex flex-col transition-colors duration-200 hover:border-primary/40 hover:bg-card/80">
      <CardHeader className="pb-3">
        <div className="flex items-start justify-between gap-3">
          <span className="font-mono text-xs text-muted-foreground">
            {String(game.number).padStart(2, "0")}
          </span>
          <div className="flex flex-wrap gap-1.5 justify-end">
            {game.tags.map((tag) => (
              <Badge key={tag} variant="secondary" className="text-xs">
                {tag}
              </Badge>
            ))}
          </div>
        </div>
        <CardTitle className="text-base font-semibold leading-snug">
          {game.title}
        </CardTitle>
        <CardDescription className="text-sm leading-relaxed">
          {game.description}
        </CardDescription>
      </CardHeader>

      <CardContent className="flex-1" />

      <CardFooter>
        <Button asChild className="w-full" size="sm">
          <a href={game.href} target="_blank" rel="noopener noreferrer">
            <ExternalLink className="h-3.5 w-3.5" />
            Play
          </a>
        </Button>
      </CardFooter>
    </Card>
  );
}

export default function App() {
  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border">
        <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6 sm:py-8">
          <div className="flex items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10 text-primary">
                <Gamepad2 className="h-5 w-5" />
              </div>
              <div>
                <h1 className="text-sm font-semibold text-foreground sm:text-base">
                  CS 470 — Game Dev Portfolio
                </h1>
                <p className="text-xs text-muted-foreground">
                  {games.length} browser games built with Godot
                </p>
              </div>
            </div>
            <Button variant="outline" size="sm" asChild>
              <a
                href="https://github.com/qs-1/gamedev"
                target="_blank"
                rel="noopener noreferrer"
              >
                <GitBranch className="h-3.5 w-3.5" />
                <span className="hidden sm:inline">Source</span>
              </a>
            </Button>
          </div>
        </div>
      </header>

      {/* Game grid */}
      <main className="mx-auto max-w-5xl px-4 py-8 sm:px-6 sm:py-10">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {games.map((game) => (
            <GameCard key={game.number} game={game} />
          ))}
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-border">
        <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6">
          <p className="text-center text-xs text-muted-foreground">
            Built with Godot 4 · Deployed on GitHub Pages
          </p>
        </div>
      </footer>
    </div>
  );
}
