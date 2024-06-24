import express from 'express';
import { 
    crearPedido, 
    agregarProductoAPedido, 
    disminuirCantidadProducto,
    listarPedidos,
    obtenerPedido ,
    eliminarPedido,
    pagarPedido,
    entregarPedido,
    eliminarProductoDePedido,
    obtenerPedidosPagadosUsuario,
    obtenerPedidosPendientesCasino,
    obtenerPedidosNoPagadosPorUsuario

} from '../controllers/pedido.controller.js';

const pedidoRouter = express.Router();

pedidoRouter.get('/', listarPedidos);
pedidoRouter.get('/:id_pedido', obtenerPedido);
pedidoRouter.post('/', crearPedido);
pedidoRouter.put('/:id_pedido/agregar', agregarProductoAPedido);
pedidoRouter.put('/:id_pedido/disminuir', disminuirCantidadProducto);
pedidoRouter.delete('/:id_pedido', eliminarPedido);
pedidoRouter.put('/:id_pedido/pagar', pagarPedido);
pedidoRouter.put('/:id_pedido/entregar', entregarPedido);
pedidoRouter.delete('/:id_pedido/eliminar/:id_producto', eliminarProductoDePedido);
pedidoRouter.get('/usuario/:id_usuario', obtenerPedidosPagadosUsuario);
pedidoRouter.get('/casino/:id_casino', obtenerPedidosPendientesCasino);
pedidoRouter.get('/usuario/:id_usuario/no_pagados', obtenerPedidosNoPagadosPorUsuario);




export default pedidoRouter;
