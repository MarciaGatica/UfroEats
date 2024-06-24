import mongoose from 'mongoose';

const pedidoSchema = new mongoose.Schema({
    id_pedido: {
        type: Number,
        min: 0,
        unique: true,  
    },
    id_usuario: {
        type: Number,
        required: true,
    },
    productos: [{
        type: Number, // Cambiado a Number
        min: 0, // Asegura que los números sean positivos
    }],
    cantidades: [{
        type: Number, // Cambiado a Number
        min: 0, // Asegura que los números sean positivos
    }],
    total: {
        type: Number,
        min: 0,
    },
    id_casino: {
        type: Number,
        min: 0,
        required: true,
    },
    entregado: {
        type: Boolean,
        required: true,
    },
    pagado: {
        type: Boolean,
        required: true,
    },
   
} );

const pedidoModel = mongoose.model('Pedido', pedidoSchema);

export default pedidoModel;
