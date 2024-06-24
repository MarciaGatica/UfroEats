import mongoose from 'mongoose';

const productoSchema = new mongoose.Schema({
    id_producto: {
        type: Number,
        min: 0,
        unique: true,  
    },
    nom_producto: {
        type: String,
        required: true,
    },
    des_producto: {
        type: String,
        required: true,
    },
    precio: {
        type: Number,
        min: 0,
        required: true,
    },
    stock: {
        type: Number,
        min: 0,
        required: true,
    },
    id_casino: {
        type: Number,
        min: 0,
        required: true,
    },
    id_categoria: {
        type: Number,
        min: 0,
        required: true,
    },
    imagen: {
        type: String, // Almacena la URL de la imagen
        required: true,
    },
} );

const productoModel = mongoose.model('Producto', productoSchema);

export default productoModel;
