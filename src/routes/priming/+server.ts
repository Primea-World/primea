import { json } from '@sveltejs/kit';

interface PrimingParagonData {
  paragonId: string | null | undefined;
  title: string | null | undefined;
  name: string | null | undefined;
  p1Games1: number | null | undefined;
  p1Games7: number | null | undefined;
  p1Games30: number | null | undefined;
  p1Games90: number | null | undefined;
  p1Games365: number | null | undefined;
  p2Games1: number | null | undefined;
  p2Games7: number | null | undefined;
  p2Games30: number | null | undefined;
  p2Games90: number | null | undefined;
  p2Games365: number | null | undefined;
  totalGames1: number | null | undefined;
  totalGames7: number | null | undefined;
  totalGames30: number | null | undefined;
  totalGames90: number | null | undefined;
  totalGames365: number | null | undefined;
  averageGameSeconds1: number | null | undefined;
  averageGameSeconds7: number | null | undefined;
  averageGameSeconds30: number | null | undefined;
  averageGameSeconds90: number | null | undefined;
  averageGameSeconds365: number | null | undefined;
  previousTotalGames1: number | null | undefined;
  previousTotalGames7: number | null | undefined;
  previousTotalGames30: number | null | undefined;
  previousTotalGames90: number | null | undefined;
  previousTotalGames365: number | null | undefined;
  p1Wins1: number | null | undefined;
  p1Wins7: number | null | undefined;
  p1Wins30: number | null | undefined;
  p1Wins90: number | null | undefined;
  p1Wins365: number | null | undefined;
  p2Wins1: number | null | undefined;
  p2Wins7: number | null | undefined;
  p2Wins30: number | null | undefined;
  p2Wins90: number | null | undefined;
  p2Wins365: number | null | undefined;
  totalWins1: number | null | undefined;
  totalWins7: number | null | undefined;
  totalWins30: number | null | undefined;
  totalWins90: number | null | undefined;
  totalWins365: number | null | undefined;
  p1WinRate1: number | null | undefined;
  p1WinRate7: number | null | undefined;
  p1WinRate30: number | null | undefined;
  p1WinRate90: number | null | undefined;
  p1WinRate365: number | null | undefined;
  p2WinRate1: | null | undefined;
  p2WinRate7: number | null | undefined;
  p2WinRate30: number | null | undefined;
  p2WinRate90: | null | undefined;
  p2WinRate365: number | null | undefined;
  totalWinRate1: number | null | undefined;
  totalWinRate7: number | null | undefined;
  totalWinRate30: number | null | undefined;
  totalWinRate90: number | null | undefined;
  totalWinRate365: number | null | undefined;
  updatedAt: string | null | undefined;
}

export const GET = async ({ fetch }) => {
  const response = await fetch(
    "https://api.priming.xyz/parallel/cards/game/list-paragon-vs-all"
  );

  const data = await response.json();

  return json(data);
}

export { type PrimingParagonData };
