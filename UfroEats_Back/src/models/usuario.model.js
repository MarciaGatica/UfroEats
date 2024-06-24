import mongoose from 'mongoose';

const usuarioSchema = new mongoose.Schema({
    id_usuario: {
        type: Number,
        min: 0,
        unique: true, // Asegura que el id_categoria sea único
    },
    nom_usuario: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
        unique: true,
    },
    clave: {
        type: String,
        required: true,
    },
    isAdmin: {
        type: Boolean,
      
    },
    favoritos: [{
        type: Number, // Cambiado a Number
        min: 0, // Asegura que los números sean positivos
    }]
});

const usuarioModel = mongoose.model('Usuario', usuarioSchema);

export default usuarioModel;
