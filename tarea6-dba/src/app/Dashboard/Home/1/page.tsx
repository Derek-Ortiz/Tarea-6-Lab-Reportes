import { getVistaCatPromedio } from "@/app/actions/reportes";
import Link from "next/link";

export default async function Report1Page() {
    const { data: datos, destacado } = await getVistaCatPromedio();
    
    return (
        <div className="p-6">
            <div className="mb-4">
                <Link href="/Dashboard/Home" className="text-blue-500 hover:underline">
                    ← Volver a reportes
                </Link>
            </div>
            <h1 className="text-2xl font-bold mb-4">Promedio de Precios por Categoría</h1>
            <p className="text-gray-600 mb-4">
                Muestra el promedio de precios agrupado por categoría, filtrando categorías con más de 2 productos.
            </p>
            
            
            {destacado && (
                <div className="bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-lg p-6 mb-6 shadow-lg">
                    <p className="text-sm uppercase tracking-wide opacity-80">Promedio más alto</p>
                    <p className="text-4xl font-bold">${destacado.promedioMasAlto}</p>
                    <p className="text-lg mt-1">{destacado.categoriaConMayorPromedio}</p>
                    <p className="text-sm opacity-70 mt-2">De {destacado.totalCategorias} categorías analizadas</p>
                </div>
            )}
            
            <div className="overflow-x-auto">
                <table className="min-w-full bg-white border border-gray-300">
                    <thead className="bg-gray-100">
                        <tr>
                            <th className="px-4 py-2 border">Categoría</th>
                            <th className="px-4 py-2 border">Cantidad Productos</th>
                            <th className="px-4 py-2 border">Promedio Precio</th>
                            <th className="px-4 py-2 border">Promedio Redondeado</th>
                        </tr>
                    </thead>
                    <tbody>
                        {datos.map((row, index) => (
                            <tr key={index} className="hover:bg-gray-50">
                                <td className="px-4 py-2 border">{row.nombre}</td>
                                <td className="px-4 py-2 border text-center">{row.cantidad_productos}</td>
                                <td className="px-4 py-2 border text-right">${Number(row.promedio_precio).toFixed(2)}</td>
                                <td className="px-4 py-2 border text-right">${row.promedio_redondeado}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}