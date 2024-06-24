import mongoose from 'mongoose';
import { MONGO_URI } from './environment.js';

async function connectDB() {
  console.log('conectado');
  return mongoose.connect(MONGO_URI).then(()=>{
    console.log('bd conectada');
    return true;
  }).catch((error)=>{
    console.log(error);
    process.exit(-1);
  });

}

export default connectDB;
