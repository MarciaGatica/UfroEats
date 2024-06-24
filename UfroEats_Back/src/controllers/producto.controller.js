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

async function crearProducto(request, response) {
    try {
        const body = request.body;
        const camposRequeridos = ['nom_producto', 'des_producto', 'precio', 'stock', 'id_casino', 'id_categoria'];

        for (const campo of camposRequeridos) {
            if (!body[campo]) {
                return response.status(400).send({
                    error: `El campo '${campo}' es obligatorio. Por favor, proporcione todos los campos requeridos.`,
                });
            }
        }

        const id_producto = await getNextSequenceValue('id_producto');

        const producto = await productoModel.create({
            id_producto,
            nom_producto: body.nom_producto,
            des_producto: body.des_producto,
            precio: body.precio,
            stock: body.stock,
            id_casino: body.id_casino,
            id_categoria: body.id_categoria,
            imagen: request.file ? request.file.filename : null, // Guardar el nombre del archivo subido
        });

        return response.status(201).send({
            producto,
            message: 'Producto creado exitosamente.',
        });
    } catch (error) {
        console.error('Error al crear producto:', error);
        return response.status(500).send({
            error: 'Hubo un error al crear el producto. Por favor, inténtelo de nuevo.',
        });
    }
}

async function listarProductos(request, response) {
    try {
        const productos = await productoModel.find({});
        return response.send({ productos });
    } catch (error) {
        console.error('Error al listar productos:', error);
        return response.status(500).send({
            error: 'Hubo un error al listar los productos. Por favor, inténtelo de nuevo.',
        });
    }
}

async function obtenerUnProducto(request, response) {
    try {
        const productoId = parseInt(request.params.productoId, 10);
        const producto = await productoModel.findOne({ id_producto: productoId });

        if (!producto) {
            return response.status(404).send({
                error: 'El producto no existe',
            });
        }

        return response.send({
            producto,
        });
    } catch (error) {
        console.error('Error al obtener el producto:', error);
        return response.status(500).send({
            error: 'Hubo un error al obtener el producto. Por favor, inténtelo de nuevo.',
        });
    }
}

async function borrarProducto(request, response) {
    try {
        const productoId = parseInt(request.params.productoId, 10);

        if (isNaN(productoId)) {
            return response.status(400).send({
                error: 'El ID del producto debe ser un número válido.',
            });
        }

        const producto = await productoModel.findOne({ id_producto: productoId });

        if (!producto) {
            return response.status(404).send({
                error: 'Producto no encontrado. No se realizó ninguna operación.',
            });
        }

        await productoModel.deleteOne({ id_producto: productoId });

        return response.status(200).send({
            success: true,
            message: 'Producto eliminado exitosamente.',
        });
    } catch (error) {
        console.error('Error al borrar producto:', error);
        return response.status(500).send({
            error: 'Hubo un error al borrar el producto. Por favor, inténtelo de nuevo.',
        });
    }
}

async function editarProducto(request, response) {
  try {
      const productoId = parseInt(request.params.productoId, 10);

      if (isNaN(productoId)) {
          return response.status(400).send({
              error: 'El id_producto debe ser un número válido.',
          });
      }

      const body = request.body;

      const producto = await productoModel.findOneAndUpdate(
          { id_producto: productoId },
          { $set: body },
          { new: true, runValidators: true }
      );

      if (!producto) {
          return response.status(404).send({
              error: 'Categoría no encontrada. No se realizó ninguna operación.',
          });
      }

      return response.status(200).send({ 
          producto,
          message: 'Categoría actualizada exitosamente.'
      });
  } catch (error) {
      console.error('Error al editar la categoría:', error);
      return response.status(500).send({
          error: 'Hubo un error al editar la categoría. Por favor, inténtelo de nuevo.',
      });
  }
}

 
async function listarProductosPorCasino(request, response) {
    try {
        const idCasino = parseInt(request.params.id_casino, 10);
        const productos = await productoModel.find({ id_casino: idCasino });

        if (!productos || productos.length === 0) {
            return response.status(404).send({
                error: 'No se encontraron productos para el casino especificado.',
            });
        }

        return response.send({ productos });
    } catch (error) {
        console.error('Error al listar productos por casino:', error);
        return response.status(500).send({
            error: 'Hubo un error al listar los productos por casino. Por favor, inténtelo de nuevo.',
        });
    }
}


export {
    crearProducto,
    listarProductos,
    borrarProducto,
    editarProducto,
    obtenerUnProducto,
    listarProductosPorCasino
};
