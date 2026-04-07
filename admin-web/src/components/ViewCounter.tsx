import { useEffect, useState } from "react";

interface ViewData {
  count: number;
}

const API_URL = "http://localhost:8082/";

export default function ViewCounter() {
  const [count, setCount] = useState<number | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchViews = async () => {
      try {
        const res = await fetch(API_URL);
        if (!res.ok) throw new Error(`HTTP error: ${res.status}`);
        const data = (await res.json()) as ViewData;
        setCount(data.count);
      } catch (err) {
        setError(err instanceof Error ? err.message : "Unknown error");
      }
    };

    fetchViews();
  }, []);

  if (error) return <p style={{ color: "red" }}>Error: {error}</p>;
  if (count === null) return <p>Loading...</p>;
  return <p>{count} views</p>;
}
