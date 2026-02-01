import { getVistaProductosMasVendidos } from "@/app/actions/reportes";
import Link from "next/link";

export default async function Report4Page({
    searchParams
}: {
    searchParams: Promise<{ page?: string; popularidad?: string }>
}) {
    const params = await searchParams;
    const page = parseInt(params.page || '1');
    const popularidad = params.popularidad || 'todos';
    
    const { data: datos, destacado, pagination } = await getVistaProductosMasVendidos({
        page,
        limit: 5,
        popularidad: popularidad as 'Muy Popular' | 'Popular' | 'todos'
    });
    
    return (
        <div className="p-6">
            <div className="mb-4">
                <Link href="/Dashboard/Home" className="text-blue-500 hover:underline">
                    ← Volver a reportes
                </Link>
            </div>
            <h1 className="text-2xl font-bold mb-4">Productos Más Vendidos</h1>
            <p className="text-gray-600 mb-4">
                Ranking de productos ordenados por cantidad vendida con clasificación de popularidad.
            </p>
            
            {/* KPI Destacado */}
            {destacado && (
                <div className="bg-gradient-to-r from-purple-500 to-violet-600 text-white rounded-lg p-6 mb-6 shadow-lg">
                    <p className="text-sm uppercase tracking-wide opacity-80">Unidades vendidas (Top 1)</p>
                    <p className="text-4xl font-bold">{destacado.cantidadVendida} uds</p>
                    <p className="text-lg mt-1">🛒 {destacado.productoMasVendido}</p>
                    <p className="text-sm opacity-70 mt-2">Ingresos totales: ${destacado.ingresosTotales}</p>
                </div>
            )}
            
            {/* Filtros */}
            <div className="mb-4 flex gap-2 flex-wrap">
                <span className="font-medium">Filtrar por popularidad:</span>
                {['todos', 'Muy Popular', 'Popular'].map((p) => (
                    <Link 
                        key={p}
                        href={`/Dashboard/Home/4?popularidad=${encodeURIComponent(p)}&page=1`}
                        className={`px-3 py-1 rounded ${popularidad === p ? 'bg-purple-500 text-white' : 'bg-gray-200 hover:bg-gray-300'}`}
                    >
                        {p}
                    </Link>
                ))}
            </div>
            
            <div className="overflow-x-auto">
                <table className="min-w-full bg-white border border-gray-300">
                    <thead className="bg-gray-100">
                        <tr>
                            <th className="px-4 py-2 border">Posición</th>
                            <th className="px-4 py-2 border">Producto</th>
                            <th className="px-4 py-2 border">Cantidad Vendida</th>
                            <th className="px-4 py-2 border">Ingresos Totales</th>
                            <th className="px-4 py-2 border">Popularidad</th>
                        </tr>
                    </thead>
                    <tbody>
                        {datos.map((row, index) => (
                            <tr key={index} className="hover:bg-gray-50">
                                <td className="px-4 py-2 border text-center">{row.posicion_ventas}</td>
                                <td className="px-4 py-2 border">{row.nombre}</td>
                                <td className="px-4 py-2 border text-center">{row.cantidad_vendida}</td>
                                <td className="px-4 py-2 border text-right">${Number(row.ingresos_totales).toFixed(2)}</td>
                                <td className="px-4 py-2 border text-center">
                                    <span className={`px-2 py-1 rounded ${
                                        row.popularidad === 'Muy Popular' ? 'bg-green-200 text-green-800' : 'bg-blue-200 text-blue-800'
                                    }`}>
                                        {row.popularidad}
                                    </span>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
            
            {/* Paginación */}
            {pagination && (
                <div className="mt-4 flex justify-center gap-2">
                    {pagination.page > 1 && (
                        <Link 
                            href={`/Dashboard/Home/4?popularidad=${encodeURIComponent(popularidad)}&page=${pagination.page - 1}`}
                            className="px-4 py-2 bg-gray-200 rounded hover:bg-gray-300"
                        >
                            Anterior
                        </Link>
                    )}
                    <span className="px-4 py-2">
                        Página {pagination.page} de {pagination.totalPages || 1}
                    </span>
                    {pagination.page < pagination.totalPages && (
                        <Link 
                            href={`/Dashboard/Home/4?popularidad=${encodeURIComponent(popularidad)}&page=${pagination.page + 1}`}
                            className="px-4 py-2 bg-gray-200 rounded hover:bg-gray-300"
                        >
                            Siguiente
                        </Link>
                    )}
                </div>
            )}
        </div>
    );
}