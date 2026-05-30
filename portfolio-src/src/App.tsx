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
    <a
      href={game.href}
      target="_blank"
      rel="noopener noreferrer"
      className="group block focus:outline-none focus-visible:ring-1 focus-visible:ring-white rounded-xl"
    >
      <Card className="h-full flex flex-col border-border bg-card transition-colors duration-150 group-hover:border-white/20 group-hover:bg-card/70">
        <CardHeader className="pb-2">
          <span className="font-mono text-xs text-muted-foreground">
            {String(game.number).padStart(2, "0")}
          </span>
          <CardTitle className="text-sm font-medium text-foreground">
            {game.title}
          </CardTitle>
        </CardHeader>
        <CardContent className="flex-1">
          <CardDescription className="text-xs leading-relaxed text-muted-foreground">
            {game.description}
          </CardDescription>
        </CardContent>
        <CardFooter className="pt-0">
          <div className="flex flex-wrap gap-1.5">
            {game.tags.map((tag) => (
              <span
                key={tag}
                className="text-[10px] font-mono text-muted-foreground/60 uppercase tracking-wider"
              >
                {tag}
              </span>
            ))}
          </div>
        </CardFooter>
      </Card>
    </a>
  );
}

export default function App() {
  return (
    <div className="min-h-screen bg-background">
      <div className="mx-auto max-w-4xl px-5 sm:px-8">

        {/* Header */}
        <header className="py-14 sm:py-20">
          <p className="font-mono text-xs text-muted-foreground mb-3 uppercase tracking-widest">
            CS 470
          </p>
          <h1 className="text-2xl sm:text-3xl font-semibold text-foreground tracking-tight">
            Game Dev Portfolio
          </h1>
          <p className="mt-2 text-sm text-muted-foreground">
            {games.length} browser games built with Godot 4 —{" "}
            <a
              href="https://github.com/qs-1/gamedev"
              target="_blank"
              rel="noopener noreferrer"
              className="text-foreground/70 underline underline-offset-4 decoration-border hover:text-foreground transition-colors"
            >
              source
            </a>
          </p>
        </header>

        {/* Divider */}
        <div className="h-px bg-border mb-10" />

        {/* Game grid */}
        <main>
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {games.map((game) => (
              <GameCard key={game.number} game={game} />
            ))}
          </div>
        </main>

        {/* Footer */}
        <footer className="py-16 mt-10">
          <p className="text-xs text-muted-foreground/50 font-mono">
            qs-1 · {new Date().getFullYear()}
          </p>
        </footer>
      </div>
    </div>
  );
}
