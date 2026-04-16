import { MongoClient } from "npm:mongodb@6.3.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

const MONGO_URI = "mongodb+srv://andresserayap17:3226325537An@basedto.zz2b4yw.mongodb.net/?appName=BaseDTO";

let client: MongoClient | null = null;

async function getDb() {
  if (!client) {
    client = new MongoClient(MONGO_URI);
    await client.connect();
  }
  return client.db("tienda");
}

function jsonResponse(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  const url = new URL(req.url);
  const path = url.pathname.replace(/^\/api/, "");

  try {
    const db = await getDb();

    if (path === "/auth/login" && req.method === "POST") {
      const { email, password } = await req.json();
      const users = db.collection("users");
      const user = await users.findOne({ email, password });
      if (user) {
        return jsonResponse({ success: true, user: { id: user._id.toString(), name: user.name, email: user.email } });
      }
      return jsonResponse({ success: false, message: "Credenciales incorrectas" }, 401);
    }

    if (path === "/auth/register" && req.method === "POST") {
      const { name, email, password } = await req.json();
      const users = db.collection("users");
      const existing = await users.findOne({ email });
      if (existing) {
        return jsonResponse({ success: false, message: "El correo ya está registrado" }, 409);
      }
      const result = await users.insertOne({ name, email, password, createdAt: new Date() });
      return jsonResponse({ success: true, user: { id: result.insertedId.toString(), name, email } });
    }

    if (path === "/products" && req.method === "GET") {
      const category = url.searchParams.get("category");
      const products = db.collection("products");
      const query = category && category !== "all" ? { category } : {};
      const data = await products.find(query).toArray();
      return jsonResponse(data.map((p) => ({ ...p, _id: p._id.toString() })));
    }

    return jsonResponse({ error: "Not found" }, 404);
  } catch (err) {
    console.error(err);
    return jsonResponse({ error: "Internal server error" }, 500);
  }
});
