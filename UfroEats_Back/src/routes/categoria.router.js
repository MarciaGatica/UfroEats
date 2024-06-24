
import express from 'express';
import {
    crearCategoria,
    borrarCategoria,
    editarCategoria,
    listarCategorias,
    obtenerCategoria
} from '../controllers/categoria.controller.js';

const categoriaRouter = express.Router();

categoriaRouter.get('/', listarCategorias);
categoriaRouter.get('/:categoriaId', obtenerCategoria);
categoriaRouter.post('/', crearCategoria);
categoriaRouter.delete('/:categoriaId', borrarCategoria);
categoriaRouter.put('/:categoriaId', editarCategoria);

export default categoriaRouter;
