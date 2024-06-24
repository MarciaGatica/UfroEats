import express from 'express';
import {
    crearProducto,
    listarProductos,
    borrarProducto,
    editarProducto,
    obtenerUnProducto,
    listarProductosPorCasino
} from '../controllers/producto.controller.js';
import upload from '../middlewares/upload.js'; // Importar el middleware de multer

const productoRouter = express.Router();

productoRouter.get('/', listarProductos);
productoRouter.get('/:productoId', obtenerUnProducto);
productoRouter.post('/', upload.single('imagen'), crearProducto); // Usar multer para manejar la subida de imágenes
productoRouter.delete('/:productoId', borrarProducto);
productoRouter.put('/:productoId', editarProducto);

productoRouter.get('/casino/:id_casino', listarProductosPorCasino);

export default productoRouter;
