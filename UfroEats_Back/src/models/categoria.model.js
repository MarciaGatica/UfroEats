import mongoose from 'mongoose';

const categoriaSchema = new mongoose.Schema({
    id_categoria: {
        type: Number,
        min: 0,
        unique: true, // Asegura que el id_categoria sea único
    },
    des_categoria: {
        type: String,
        required: true,
    },
} );

// Como no existe el campo `nombre`, no definimos el índice en ese campo
// Si quieres definir un índice en `des_categoria`, puedes hacerlo de la siguiente manera:
categoriaSchema.index({ des_categoria: 1 });

const categoriaModel = mongoose.model('Categoria', categoriaSchema);

export default categoriaModel;
