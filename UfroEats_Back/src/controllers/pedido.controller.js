import pedidoModel from '../models/pedido.model.js';
import productoModel from '../models/producto.model.js';
import Counter from '../models/counter.model.js'; // Importa tu modelo de contador

async function getNextSequenceValue(sequenceName) {
  const sequenceDocument = await Counter.findOneAndUpdate(
      { _id: sequenceName },
      { $inc: { sequence_value: 1 } },
      { new: true, upsert: true }
  );
  return sequenceDocument.sequence_value;
}
async function obtenerPedido(request, response) {
    try {
        const id_pedido = parseInt(request.params.id_pedido, 10);

        if (isNaN(id_pedido)) {
            return response.status(400).send({
                error: 'El id_pedido debe ser un número válido.',
            });
        }

        const pedido = await pedidoModel.findOne({ id_pedido });

        if (!pedido) {
            return response.status(404).send({
                error: 'Pedido no encontrado.',
            });
        }

        return response.send({ pedido });
    } catch (error) {
        console.error('Error al obtener el pedido:', error);
        return response.status(500).send({
            error: 'Hubo un error al obtener el pedido. Por favor, inténtelo de nuevo.',
        });
    }
}

async function listarPedidos(request, response) {
    try {
        const pedidos = await pedidoModel.find({});
        return response.send({ pedidos });
    } catch (error) {
        console.error('Error al listar los pedidos:', error);
        return response.status(500).send({
            error: 'Hubo un error al listar los pedidos. Por favor, inténtelo de nuevo.',
        });
    }
}

async function crearPedido(request, response) {
    try {
        const { id_usuario, productos, cantidades, id_casino } = request.body;
        
        if (!id_usuario || !productos || !cantidades || !id_casino) {
            return response.status(400).send({
                error: 'Todos los campos son obligatorios.',
            });
        }

        if (productos.length !== cantidades.length) {
            return response.status(400).send({
                error: 'El número de productos debe coincidir con el número de cantidades.',
            });
        }

        let total = 0;

        for (let i = 0; i < productos.length; i++) {
            const producto = await productoModel.findOne({ id_producto: productos[i] });
            if (!producto) {
                return response.status(404).send({
                    error: `El producto con id ${productos[i]} no existe.`,
                });
            }
            total += producto.precio * cantidades[i];
        }

        const id_pedido = await getNextSequenceValue('id_pedido');

        const pedido = await pedidoModel.create({
            id_pedido,
            id_usuario,
            productos,
            cantidades,
            total,
            id_casino,
            entregado: false,
            pagado: false,
        });

        return response.status(201).send({
            pedido,
            message: 'Pedido creado exitosamente.',
        });
    } catch (error) {
        console.error('Error al crear pedido:', error);
        return response.status(500).send({
            error: 'Hubo un error al crear el pedido. Por favor, inténtelo de nuevo.',
        });
    }
}

async function agregarProductoAPedido(request, response) {
    try {
        const { id_pedido } = request.params;
        const { productos, cantidades } = request.body;

        if (!productos || !cantidades || productos.length !== cantidades.length) {
            return response.status(400).send({
                error: 'Debe proporcionar productos y cantidades válidos.',
            });
        }

        const pedido = await pedidoModel.findOne({ id_pedido: parseInt(id_pedido, 10) });

        if (!pedido) {
            return response.status(404).send({
                error: 'Pedido no encontrado.',
            });
        }

        let total = pedido.total;

        for (let i = 0; i < productos.length; i++) {
            const producto = await productoModel.findOne({ id_producto: productos[i] });
            if (!producto) {
                return response.status(404).send({
                    error: `El producto con id ${productos[i]} no existe.`,
                });
            }

            const index = pedido.productos.indexOf(productos[i]);
            if (index !== -1) {
                // El producto ya existe en el pedido, suma la cantidad
                pedido.cantidades[index] += cantidades[i];
            } else {
                // El producto no existe en el pedido, añádelo
                pedido.productos.push(productos[i]);
                pedido.cantidades.push(cantidades[i]);
            }

            total += producto.precio * cantidades[i];
        }

        pedido.total = total;

        await pedido.save();

        return response.status(200).send({
            pedido,
            message: 'Productos añadidos exitosamente al pedido.',
        });
    } catch (error) {
        console.error('Error al añadir productos al pedido:', error);
        return response.status(500).send({
            error: 'Hubo un error al añadir productos al pedido. Por favor, inténtelo de nuevo.',
        });
    }
}

async function disminuirCantidadProducto(request, response) {
    try {
        const { id_pedido } = request.params;
        const { id_producto, cantidad } = request.body;

        if (!id_producto || !cantidad) {
            return response.status(400).send({
                error: 'Debe proporcionar id_producto y cantidad válidos.',
            });
        }

        const pedido = await pedidoModel.findOne({ id_pedido: parseInt(id_pedido, 10) });

        if (!pedido) {
            return response.status(404).send({
                error: 'Pedido no encontrado.',
            });
        }

        const index = pedido.productos.indexOf(id_producto);

        if (index === -1) {
            return response.status(404).send({
                error: `El producto con id ${id_producto} no existe en el pedido.`,
            });
        }

        const producto = await productoModel.findOne({ id_producto: id_producto });
        if (!producto) {
            return response.status(404).send({
                error: `El producto con id ${id_producto} no existe.`,
            });
        }

        if (pedido.cantidades[index] < cantidad) {
            return response.status(400).send({
                error: 'La cantidad a disminuir es mayor que la cantidad actual en el pedido.',
            });
        }

        // Disminuir la cantidad
        pedido.cantidades[index] -= cantidad;
        let totalDisminuido = producto.precio * cantidad;
        pedido.total -= totalDisminuido;

        // Eliminar el producto si la cantidad llega a 0
        if (pedido.cantidades[index] === 0) {
            pedido.productos.splice(index, 1);
            pedido.cantidades.splice(index, 1);
        }

        await pedido.save();

        return response.status(200).send({
            pedido,
            message: 'Cantidad de producto disminuida exitosamente.',
        });
    } catch (error) {
        console.error('Error al disminuir cantidad del producto en el pedido:', error);
        return response.status(500).send({
            error: 'Hubo un error al disminuir la cantidad del producto en el pedido. Por favor, inténtelo de nuevo.',
        });
    }
}

async function eliminarPedido(request, response) {
    try {
        const id_pedido = parseInt(request.params.id_pedido, 10);

        if (isNaN(id_pedido)) {
            return response.status(400).send({
                error: 'El id_pedido debe ser un número válido.',
            });
        }

        const pedido = await pedidoModel.findOne({ id_pedido });

        if (!pedido) {
            return response.status(404).send({
                error: 'Pedido no encontrado.',
            });
        }

        await pedidoModel.deleteOne({ id_pedido });

        return response.status(200).send({
            success: true,
            message: 'Pedido eliminado exitosamente.',
        });
    } catch (error) {
        console.error('Error al eliminar el pedido:', error);
        return response.status(500).send({
            error: 'Hubo un error al eliminar el pedido. Por favor, inténtelo de nuevo.',
        });
    }
}

async function pagarPedido(request, response) {
    try {
        const id_pedido = parseInt(request.params.id_pedido, 10);

        if (isNaN(id_pedido)) {
            return response.status(400).send({
                error: 'El id_pedido debe ser un número válido.',
            });
        }

        const pedido = await pedidoModel.findOne({ id_pedido });

        if (!pedido) {
            return response.status(404).send({
                error: 'Pedido no encontrado.',
            });
        }

        // Verificar si el pedido ya ha sido pagado
        if (pedido.pagado) {
            return response.status(400).send({
                error: 'El pedido ya ha sido pagado anteriormente.',
            });
        }

        // Verificar si hay suficiente stock para todos los productos en el pedido
        for (let i = 0; i < pedido.productos.length; i++) {
            const producto = await productoModel.findOne({ id_producto: pedido.productos[i] });

            if (!producto) {
                return response.status(404).send({
                    error: `El producto con id ${pedido.productos[i]} no existe.`,
                });
            }

            if (producto.stock < pedido.cantidades[i]) {
                return response.status(400).send({
                    error: `No hay suficiente stock para el producto con id ${pedido.productos[i]}.`,
                });
            }
        }

        // Actualizar el stock y el atributo pagado del pedido
        for (let i = 0; i < pedido.productos.length; i++) {
            const producto = await productoModel.findOne({ id_producto: pedido.productos[i] });

            producto.stock -= pedido.cantidades[i];
            await producto.save();
        }

        pedido.pagado = true;
        await pedido.save();

        return response.status(200).send({
            success: true,
            message: 'Pedido pagado exitosamente.',
        });
    } catch (error) {
        console.error('Error al pagar el pedido:', error);
        return response.status(500).send({
            error: 'Hubo un error al pagar el pedido. Por favor, inténtelo de nuevo.',
        });
    }
}

async function entregarPedido(request, response) {
    try {
        const id_pedido = parseInt(request.params.id_pedido, 10);

        if (isNaN(id_pedido)) {
            return response.status(400).send({
                error: 'El id_pedido debe ser un número válido.',
            });
        }

        const pedido = await pedidoModel.findOne({ id_pedido });

        if (!pedido) {
            return response.status(404).send({
                error: 'Pedido no encontrado.',
            });
        }

        // Verificar si el pedido ya ha sido entregado
        if (pedido.entregado) {
            return response.status(400).send({
                error: 'El pedido ya ha sido entregado anteriormente.',
            });
        }

        // Marcar el pedido como entregado
        pedido.entregado = true;
        await pedido.save();

        return response.status(200).send({
            success: true,
            message: 'Pedido entregado exitosamente.',
        });
    } catch (error) {
        console.error('Error al marcar el pedido como entregado:', error);
        return response.status(500).send({
            error: 'Hubo un error al marcar el pedido como entregado. Por favor, inténtelo de nuevo.',
        });
    }
}

async function eliminarProductoDePedido(request, response) {
    try {
        const id_pedido = parseInt(request.params.id_pedido, 10);
        const id_producto = parseInt(request.params.id_producto, 10);

        if (isNaN(id_pedido) || isNaN(id_producto)) {
            return response.status(400).send({
                error: 'Los IDs del pedido y del producto deben ser números válidos.',
            });
        }

        const pedido = await pedidoModel.findOne({ id_pedido });

        if (!pedido) {
            return response.status(404).send({
                error: 'Pedido no encontrado.',
            });
        }

        const index = pedido.productos.indexOf(id_producto);
        if (index === -1) {
            return response.status(404).send({
                error: 'El producto no está en la lista del pedido.',
            });
        }

        // Eliminar el producto de la lista de productos y cantidades
        pedido.productos.splice(index, 1);
        pedido.cantidades.splice(index, 1);

        await pedido.save();

        return response.status(200).send({
            success: true,
            message: 'Producto eliminado del pedido exitosamente.',
        });
    } catch (error) {
        console.error('Error al eliminar el producto del pedido:', error);
        return response.status(500).send({
            error: 'Hubo un error al eliminar el producto del pedido. Por favor, inténtelo de nuevo.',
        });
    }
}


async function obtenerPedidosPagadosUsuario(request, response) {
    try {
        const id_usuario = parseInt(request.params.id_usuario, 10);

        if (isNaN(id_usuario)) {
            return response.status(400).send({
                error: 'El ID del usuario debe ser un número válido.',
            });
        }

        const pedidos = await pedidoModel.find({ id_usuario, pagado: true, entregado: false });

        return response.status(200).send({
            pedidos,
        });
    } catch (error) {
        console.error('Error al obtener los pedidos por usuario:', error);
        return response.status(500).send({
            error: 'Hubo un error al obtener los pedidos por usuario. Por favor, inténtelo de nuevo.',
        });
    }
}

async function obtenerPedidosPendientesCasino(request, response) {
    try {
        const id_casino = parseInt(request.params.id_casino, 10);

        if (isNaN(id_casino)) {
            return response.status(400).send({
                error: 'El ID del casino debe ser un número válido.',
            });
        }

        const pedidos = await pedidoModel.find({ id_casino, pagado: true, entregado: false });

        return response.status(200).send({
            pedidos,
        });
    } catch (error) {
        console.error('Error al obtener los pedidos por casino:', error);
        return response.status(500).send({
            error: 'Hubo un error al obtener los pedidos por casino. Por favor, inténtelo de nuevo.',
        });
    }
}

async function obtenerPedidosNoPagadosPorUsuario(request, response) {
    try {
        const id_usuario = parseInt(request.params.id_usuario, 10);

        if (isNaN(id_usuario)) {
            return response.status(400).send({
                error: 'El ID del usuario debe ser un número válido.',
            });
        }

        const pedidos = await pedidoModel.find({ id_usuario, pagado: false });

        return response.status(200).send({
            pedidos,
        });
    } catch (error) {
        console.error('Error al obtener los pedidos no pagados por usuario:', error);
        return response.status(500).send({
            error: 'Hubo un error al obtener los pedidos no pagados por usuario. Por favor, inténtelo de nuevo.',
        });
    }
}





export { crearPedido, 
    agregarProductoAPedido, 
    disminuirCantidadProducto ,
    obtenerPedido, 
    listarPedidos, 
    eliminarPedido,
    pagarPedido,
    entregarPedido,
    eliminarProductoDePedido,
    obtenerPedidosPagadosUsuario,
    obtenerPedidosPendientesCasino,
    obtenerPedidosNoPagadosPorUsuario
};
