import categoriaModel from '../models/categoria.model.js';
import Counter from '../models/counter.model.js'; // Importa tu modelo de contador

 
async function obtenerCategoria(request, response) {
  try {
      const categoriaId = parseInt(request.params.categoriaId, 10); // Asegúrate de convertir a número

      if (isNaN(categoriaId)) {
          return response.status(400).send({
              error: 'El id_categoria debe ser un número válido.',
          });
      }

      const categoria = await categoriaModel.findOne({ id_categoria: categoriaId });

      if (!categoria) {
          return response.status(404).send({
              error: 'La categoría no existe',
          });
      }

      return response.send({
          categoria,
      });
  } catch (error) {
      console.error('Error al obtener la categoría:', error);
      return response.status(500).send({
          error: 'Hubo un error al obtener la categoría. Por favor, inténtelo de nuevo.',
      });
  }
}


async function listarCategorias(request, response) {
    const page = request.query.page;
  
    const categoria = await categoriaModel.find({});
  
    return response.send({
        categoria
    });
  }
  

  async function getNextSequenceValue(sequenceName) {
    const sequenceDocument = await Counter.findOneAndUpdate(
        { _id: sequenceName },
        { $inc: { sequence_value: 1 } },
        { new: true, upsert: true }
    );
    return sequenceDocument.sequence_value;
}

async function crearCategoria(request, response) {
    try {
        const body = request.body;
        const camposRequeridos = ['des_categoria'];

        for (const campo of camposRequeridos) {
            if (!body[campo]) {
                return response.status(400).send({
                    error: `El campo '${campo}' es obligatorio. Por favor, proporcione todos los campos requeridos.`,
                });
            }
        }

        const id_categoria = await getNextSequenceValue('id_categoria');

        const categoria = await categoriaModel.create({
            id_categoria,
            des_categoria: body.des_categoria,
        });

        return response.status(201).send({
            categoria,
            message: 'Categoría creada exitosamente.',
        });
    } catch (error) {
        console.error('Error al crear categoría:', error);
        return response.status(500).send({
            error: 'Hubo un error al crear la categoría. Por favor, inténtelo de nuevo.',
        });
    }
}


async function borrarCategoria(request, response) {
  try {
      const categoriaId = parseInt(request.params.categoriaId, 10); // Asegúrate de convertir a número
      if (isNaN(categoriaId)) {
          return response.status(400).send({
              error: 'El id_categoria debe ser un número válido.',
          });
      }

      const categoria = await categoriaModel.findOne({ id_categoria: categoriaId });

      if (!categoria) {
          return response.status(404).send({
              error: 'Categoría no encontrada. No se realizó ninguna operación.',
          });
      }
      
      await categoriaModel.deleteOne({ id_categoria: categoriaId });

      return response.status(200).send({
          success: true,
          message: 'Categoría eliminada exitosamente.',
      });
  } catch (error) {
      console.error('Error al borrar categoría:', error);
      return response.status(500).send({
          error: 'Hubo un error al borrar la categoría. Por favor, inténtelo de nuevo.',
      });
  }
}

 


async function editarCategoria(request, response) {
  try {
      const categoriaId = parseInt(request.params.categoriaId, 10);

      if (isNaN(categoriaId)) {
          return response.status(400).send({
              error: 'El id_categoria debe ser un número válido.',
          });
      }

      const body = request.body;

      const categoria = await categoriaModel.findOneAndUpdate(
          { id_categoria: categoriaId },
          { $set: body },
          { new: true, runValidators: true }
      );

      if (!categoria) {
          return response.status(404).send({
              error: 'Categoría no encontrada. No se realizó ninguna operación.',
          });
      }

      return response.status(200).send({ 
          categoria,
          message: 'Categoría actualizada exitosamente.'
      });
  } catch (error) {
      console.error('Error al editar la categoría:', error);
      return response.status(500).send({
          error: 'Hubo un error al editar la categoría. Por favor, inténtelo de nuevo.',
      });
  }
}

 



export {
  obtenerCategoria,
  listarCategorias,
  crearCategoria,
  borrarCategoria,
  editarCategoria
};
