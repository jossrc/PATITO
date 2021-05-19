package interfaces;

import java.util.ArrayList;

import beans.ProductoDTO;

public interface ProductoDAO {
    
    public int registrar(ProductoDTO p);
    public int eliminar(ProductoDTO p);
    public int actualizar(ProductoDTO p);
    public ArrayList<ProductoDTO> listadoCategoria();

}
