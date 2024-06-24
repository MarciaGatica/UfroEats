import jwt from 'jsonwebtoken';
import { JWT_SECRET } from '../config/environment.js';

function authMiddleware(req, res, next) {
  const bearerToken =
    req.headers['Authorization'] || req.headers['authorization'];

  try {
    const token = bearerToken.split(' ')[1];

    if (!token) {
      return res.status(401).send({ error: 'Falta el token' });
    }

    const payload = jwt.verify(token, JWT_SECRET);
    req.userId = payload.userId;

    next();
  } catch (error) {
    return res.status(401).send({ error: 'Error de token' });
  }
}

export default authMiddleware;