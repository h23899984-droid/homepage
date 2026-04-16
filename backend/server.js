const express = require('express');
const cors = require('cors');
const { MongoClient, ObjectId } = require('mongodb');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI;
const DB_NAME = process.env.DB_NAME || 'tienda';

let db;
const client = new MongoClient(MONGODB_URI);

app.use(cors());
app.use(express.json());

async function setupCollections() {
  const collections = await db.listCollections().toArray();
  const names = collections.map(c => c.name);

  if (!names.includes('users')) {
    await db.createCollection('users');
    await db.collection('users').createIndex({ email: 1 }, { unique: true });
    console.log('✓ Colección users creada');
  }

  if (!names.includes('products')) {
    await db.createCollection('products');
    await db.collection('products').createIndex({ category: 1 });
    await db.collection('products').createIndex({ name: 'text', description: 'text' });
    console.log('✓ Colección products creada');
  }

  if (!names.includes('carts')) {
    await db.createCollection('carts');
    await db.collection('carts').createIndex({ userId: 1 }, { unique: true });
    console.log('✓ Colección carts creada');
  }

  if (!names.includes('orders')) {
    await db.createCollection('orders');
    await db.collection('orders').createIndex({ userId: 1 });
    await db.collection('orders').createIndex({ createdAt: -1 });
    console.log('✓ Colección orders creada');
  }
}

async function connectDB() {
  try {
    await client.connect();
    db = client.db(DB_NAME);
    console.log('✓ Conectado a MongoDB');
    await setupCollections();
  } catch (err) {
    console.error('✗ Error conectando a MongoDB:', err);
    process.exit(1);
  }
}

// Auth Routes

app.post('/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Correo y contraseña requeridos' });
    }
    const users = db.collection('users');
    const user = await users.findOne({ email, password });

    if (user) {
      return res.json({
        success: true,
        user: { id: user._id.toString(), name: user.name, email: user.email }
      });
    }

    return res.status(401).json({ success: false, message: 'Credenciales incorrectas' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

app.post('/auth/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ success: false, message: 'Todos los campos son requeridos' });
    }
    const users = db.collection('users');

    const existing = await users.findOne({ email });
    if (existing) {
      return res.status(409).json({ success: false, message: 'El correo ya está registrado' });
    }

    const result = await users.insertOne({ name, email, password, createdAt: new Date() });

    res.json({
      success: true,
      user: { id: result.insertedId.toString(), name, email }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

app.get('/auth/profile/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const users = db.collection('users');
    const user = await users.findOne({ _id: new ObjectId(userId) });

    if (!user) {
      return res.status(404).json({ success: false, message: 'Usuario no encontrado' });
    }

    res.json({
      success: true,
      user: { id: user._id.toString(), name: user.name, email: user.email, createdAt: user.createdAt }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

// Product Routes

app.get('/products', async (req, res) => {
  try {
    const { category, search } = req.query;
    const products = db.collection('products');

    let query = {};
    if (category && category !== 'all') query.category = category;
    if (search) query.$text = { $search: search };

    const data = await products.find(query).toArray();
    res.json(data.map(p => ({ ...p, _id: p._id.toString() })));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

app.get('/products/:id', async (req, res) => {
  try {
    const products = db.collection('products');
    const product = await products.findOne({ _id: new ObjectId(req.params.id) });

    if (!product) {
      return res.status(404).json({ success: false, message: 'Producto no encontrado' });
    }

    res.json({ ...product, _id: product._id.toString() });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

// Cart Routes

app.get('/cart/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const carts = db.collection('carts');
    const cart = await carts.findOne({ userId });

    if (!cart) {
      return res.json({ success: true, items: [] });
    }

    res.json({ success: true, items: cart.items || [] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

app.post('/cart/:userId/add', async (req, res) => {
  try {
    const { userId } = req.params;
    const { productId, name, price, image_url, quantity = 1 } = req.body;

    if (!productId || !name || price === undefined) {
      return res.status(400).json({ success: false, message: 'Datos del producto requeridos' });
    }

    const carts = db.collection('carts');
    const cart = await carts.findOne({ userId });

    if (cart) {
      const itemIndex = cart.items.findIndex(i => i.productId === productId);
      if (itemIndex > -1) {
        cart.items[itemIndex].quantity += quantity;
        await carts.updateOne({ userId }, { $set: { items: cart.items, updatedAt: new Date() } });
      } else {
        await carts.updateOne(
          { userId },
          { $push: { items: { productId, name, price, image_url, quantity } }, $set: { updatedAt: new Date() } }
        );
      }
    } else {
      await carts.insertOne({
        userId,
        items: [{ productId, name, price, image_url, quantity }],
        createdAt: new Date(),
        updatedAt: new Date()
      });
    }

    const updated = await carts.findOne({ userId });
    res.json({ success: true, items: updated.items });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

app.put('/cart/:userId/item/:productId', async (req, res) => {
  try {
    const { userId, productId } = req.params;
    const { quantity } = req.body;

    if (quantity < 1) {
      return res.status(400).json({ success: false, message: 'Cantidad debe ser mayor a 0' });
    }

    const carts = db.collection('carts');
    const cart = await carts.findOne({ userId });

    if (!cart) {
      return res.status(404).json({ success: false, message: 'Carrito no encontrado' });
    }

    const items = cart.items.map(i =>
      i.productId === productId ? { ...i, quantity } : i
    );

    await carts.updateOne({ userId }, { $set: { items, updatedAt: new Date() } });
    res.json({ success: true, items });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

app.delete('/cart/:userId/item/:productId', async (req, res) => {
  try {
    const { userId, productId } = req.params;
    const carts = db.collection('carts');

    const cart = await carts.findOne({ userId });
    if (!cart) {
      return res.status(404).json({ success: false, message: 'Carrito no encontrado' });
    }

    const items = cart.items.filter(i => i.productId !== productId);
    await carts.updateOne({ userId }, { $set: { items, updatedAt: new Date() } });
    res.json({ success: true, items });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

app.delete('/cart/:userId/clear', async (req, res) => {
  try {
    const { userId } = req.params;
    const carts = db.collection('carts');
    await carts.updateOne({ userId }, { $set: { items: [], updatedAt: new Date() } });
    res.json({ success: true, items: [] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

// Order Routes

app.post('/orders', async (req, res) => {
  try {
    const { userId, items, total, address, paymentMethod = 'efectivo' } = req.body;

    if (!userId || !items || !items.length || !total) {
      return res.status(400).json({ success: false, message: 'Datos del pedido incompletos' });
    }

    const orders = db.collection('orders');
    const result = await orders.insertOne({
      userId,
      items,
      total,
      address: address || '',
      paymentMethod,
      status: 'pendiente',
      createdAt: new Date(),
      updatedAt: new Date()
    });

    const carts = db.collection('carts');
    await carts.updateOne({ userId }, { $set: { items: [], updatedAt: new Date() } });

    res.json({
      success: true,
      order: {
        id: result.insertedId.toString(),
        userId,
        items,
        total,
        status: 'pendiente',
        createdAt: new Date()
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

app.get('/orders/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const orders = db.collection('orders');
    const data = await orders.find({ userId }).sort({ createdAt: -1 }).toArray();

    res.json(data.map(o => ({ ...o, _id: o._id.toString() })));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

app.get('/orders/:userId/:orderId', async (req, res) => {
  try {
    const { userId, orderId } = req.params;
    const orders = db.collection('orders');
    const order = await orders.findOne({ _id: new ObjectId(orderId), userId });

    if (!order) {
      return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
    }

    res.json({ ...order, _id: order._id.toString() });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

app.put('/orders/:userId/:orderId/cancel', async (req, res) => {
  try {
    const { userId, orderId } = req.params;
    const orders = db.collection('orders');

    const order = await orders.findOne({ _id: new ObjectId(orderId), userId });
    if (!order) {
      return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
    }

    if (order.status !== 'pendiente') {
      return res.status(400).json({ success: false, message: 'Solo se pueden cancelar pedidos pendientes' });
    }

    await orders.updateOne(
      { _id: new ObjectId(orderId) },
      { $set: { status: 'cancelado', updatedAt: new Date() } }
    );

    res.json({ success: true, message: 'Pedido cancelado' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`Server corriendo en puerto ${PORT}`);
  });
});

process.on('SIGINT', async () => {
  await client.close();
  process.exit(0);
});
