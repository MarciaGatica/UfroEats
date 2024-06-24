import usuarioModel from '../models/usuario.model.js';

async function isadmin(req, res, next) {
  try {
    const userId = req.userId;

    const user = await usuarioModel.findById(userId);

    if (!user.isAdmin) {
      return res.status(403).send({ error: 'No eres admin' });
    }

    next();
  } catch (error) {
    return res.status(401).send({ error: 'Error de token' });
  }
}

export default isadmin;