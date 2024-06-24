import express from 'express';

import productoRouter from './src/routes/producto.router.js';
import usuarioRouter from './src/routes/usuario.router.js';
import categoriaRouter from './src/routes/categoria.router.js';
import pedidoRouter from './src/routes/pedido.router.js';

import { PORT } from './src/config/environment.js';
import connectDB from './src/config/mongo.js';
import cors from 'cors';



const app = express();

app.use(express.json());
app.use(cors({
  origin: 'http://localhost:5173',  // Reemplaza con la URL de tu aplicación Vue
}));

app.use('/producto', productoRouter);
app.use('/usuario', usuarioRouter);
app.use("/categoria",categoriaRouter);
app.use("/pedido",pedidoRouter);
app.use('/uploads', express.static('uploads'));

async function startServer() {
  const isConnected = await connectDB();
  if (isConnected) {
    app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
  }
}

startServer();
