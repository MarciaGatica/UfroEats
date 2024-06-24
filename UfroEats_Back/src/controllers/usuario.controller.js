import usuarioModel from '../models/usuario.model.js';
import Counter from '../models/counter.model.js'; // Importa tu modelo de contador


async function getNextSequenceValue(sequenceName) {
  const sequenceDocument = await Counter.findOneAndUpdate(
      { _id: sequenceName },
      { $inc: { sequence_value: 1 } },
      { new: true, upsert: true }
  );
  return sequenceDocument.sequence_value;
}


async function obtenerUnUsuario(request, response) {
  try {
      const usuarioId = parseInt(request.params.usuarioId, 10); // Asegúrate de convertir a número

      if (isNaN(usuarioId)) {
          return response.status(400).send({
              error: 'El usuario debe ser un número válido.',
          });
      }

      const usuario = await usuarioModel.findOne({ id_usuario: usuarioId });

      if (!usuario) {
          return response.status(404).send({
              error: 'La usuario no existe',
          });
      }

      return response.send({
        usuario,
      });
  } catch (error) {
      console.error('Error al obtener la usuario:', error);
      return response.status(500).send({
          error: 'Hubo un error al obtener la usuario. Por favor, inténtelo de nuevo.',
      });
  }
}


async function listarUsuarios(request, response) {
  try {
    const usuarios = await usuarioModel.find({});
    return response.send({
      usuarios
    });
  } catch (error) {
    return response.status(500).send({
      error: 'Hubo un error al listar los usuarios. Por favor, inténtelo de nuevo.',
    });
  }
}

async function crearUsuario(request, response) {
  try {
      const body = request.body;
      const camposRequeridos = ['nom_usuario', 'email', 'clave'];

      for (const campo of camposRequeridos) {
          if (!body[campo]) {
              return response.status(400).send({
                  error: `El campo '${campo}' es obligatorio. Por favor, proporcione todos los campos requeridos.`,
              });
          }
      }

      const id_usuario = await getNextSequenceValue('id_usuario');

      const usuario = await usuarioModel.create({
          id_usuario,
          nom_usuario: body.nom_usuario,
          email: body.email,
          clave: body.clave,
          isAdmin: body.isAdmin,
          favoritos: body.favoritos,
      });

      return response.status(201).send({
          usuario,
          message: 'usuario creada exitosamente.',
      });
  } catch (error) {
      console.error('Error al crear usuario:', error);
      return response.status(500).send({
          error: 'Hubo un error al crear la usuario. Por favor, inténtelo de nuevo.',
      });
  }
}

async function borrarUsuario(request, response) {
  try {
      const usuarioId = parseInt(request.params.usuarioId, 10); // Asegúrate de convertir a número
      if (isNaN(usuarioId)) {
          return response.status(400).send({
              error: 'El usuario debe ser un número válido.',
          });
      }

      const usuario = await usuarioModel.findOne({ id_usuario: usuarioId });

      if (!usuario) {
          return response.status(404).send({
              error: 'usuario no encontrada. No se realizó ninguna operación.',
          });
      }
      
      await usuarioModel.deleteOne({ id_usuario: usuarioId });

      return response.status(200).send({
          success: true,
          message: 'usuario eliminada exitosamente.',
      });
  } catch (error) {
      console.error('Error al borrar usuario:', error);
      return response.status(500).send({
          error: 'Hubo un error al borrar la usuario. Por favor, inténtelo de nuevo.',
      });
  }
}

  

async function editarUsuario(request, response) {
  try {
      const usuarioId = parseInt(request.params.usuarioId, 10);

      if (isNaN(usuarioId)) {
          return response.status(400).send({
              error: 'El id_usuario debe ser un número válido.',
          });
      }

      const body = request.body;

      const usuario = await usuarioModel.findOneAndUpdate(
          { id_usuario: usuarioId },
          { $set: body },
          { new: true, runValidators: true }
      );

      if (!usuario) {
          return response.status(404).send({
              error: 'usuario no encontrada. No se realizó ninguna operación.',
          });
      }

      return response.status(200).send({ 
        usuario,
          message: 'usuario actualizada exitosamente.'
      });
  } catch (error) {
      console.error('Error al editar la usuario:', error);
      return response.status(500).send({
          error: 'Hubo un error al editar la categoría. Por favor, inténtelo de nuevo.',
      });
  }
}

async function agregarFavorito(request, response) {
  try {
    const usuarioId = parseInt(request.params.usuarioId, 10);
    const productoId = parseInt(request.body.productoId, 10);

    // Verificar si el usuario existe
    const usuario = await usuarioModel.findOne({ id_usuario: usuarioId });
    if (!usuario) {
      return response.status(404).send({
        error: 'El usuario no existe',
      });
    }

    /* Verificar si el producto existe (esto depende de tu lógica de negocio)
    const producto = await productoModel.findOne({ id_producto: productoId });
    if (!producto) {
      return response.status(404).send({
        error: 'El producto no existe',
      });
    }*/

    // Verificar si el producto ya está en la lista de favoritos del usuario
    if (usuario.favoritos.includes(productoId)) {
      return response.status(400).send({
        error: 'El producto ya está en la lista de favoritos del usuario',
      });
    }

    // Agregar el producto a la lista de favoritos del usuario
    usuario.favoritos.push(productoId);
    await usuario.save();

    return response.status(200).send({
      message: 'Producto agregado a la lista de favoritos exitosamente',
    });
  } catch (error) {
    console.error('Error al agregar producto a favoritos:', error);
    return response.status(500).send({
      error: 'Hubo un error al agregar producto a favoritos. Por favor, inténtelo de nuevo.',
    });
  }
}
 

async function eliminarFavorito(request, response) {
  try {
    const usuarioId = parseInt(request.params.usuarioId, 10);
    const productoId = parseInt(request.body.productoId, 10);

    // Verificar si el usuario existe
    const usuario = await usuarioModel.findOne({ id_usuario: usuarioId });
    if (!usuario) {
      return response.status(404).send({
        error: 'El usuario no existe',
      });
    }

    // Verificar si el producto existe (esto depende de tu lógica de negocio)
    const productoIndex = usuario.favoritos.indexOf(productoId);
    if (productoIndex === -1) {
      return response.status(404).send({
        error: 'El producto no está en la lista de favoritos del usuario',
      });
    }

    // Eliminar el producto de la lista de favoritos del usuario
    usuario.favoritos.splice(productoIndex, 1);
    await usuario.save();

    return response.status(200).send({
      message: 'Producto eliminado de la lista de favoritos exitosamente',
    });
  } catch (error) {
    console.error('Error al eliminar producto de favoritos:', error);
    return response.status(500).send({
      error: 'Hubo un error al eliminar producto de favoritos. Por favor, inténtelo de nuevo.',
    });
  }
}


async function iniciarSesion(request, response) {
  try {
      const { email, clave } = request.body;

      // Verificar si se proporcionaron el email y la clave
      if (!email || !clave) {
          return response.status(400).send({
              error: 'El email y la clave son obligatorios.',
          });
      }

      // Verificar si el usuario existe
      const usuario = await usuarioModel.findOne({ email });
      if (!usuario) {
          return response.status(404).send({
              error: 'El usuario no existe',
          });
      }

      // Verificar si la clave es correcta
      if (usuario.clave !== clave) {
          return response.status(401).send({
              error: 'Credenciales incorrectas',
          });
      }

      return response.status(200).send({
          message: 'Inicio de sesión exitoso',
          usuario: {
              id_usuario: usuario.id_usuario,
              nom_usuario: usuario.nom_usuario,
              email: usuario.email,
              isAdmin: usuario.isAdmin,
              favoritos: usuario.favoritos,
          },
      });
  } catch (error) {
      console.error('Error al iniciar sesión:', error);
      return response.status(500).send({
          error: 'Hubo un error al iniciar sesión. Por favor, inténtelo de nuevo.',
      });
  }
}

export {
  obtenerUnUsuario,
  listarUsuarios,
  crearUsuario,
  borrarUsuario,
  editarUsuario,
  agregarFavorito,
  eliminarFavorito,
  iniciarSesion
};
