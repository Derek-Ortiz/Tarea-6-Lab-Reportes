import { getVistaRankingUsuarios } from "@/lib/reportes";
import Link from "next/link";

export default async function Report2Page({
    searchParams
}: {
    searchParams: Promise<{ page?: string; nivel?: string }>
}) {
    const params = await searchParams;
    const page = parseInt(params.page || '1');
    const nivel = params.nivel || 'todos';
    
    const { data: datos, destacado, pagination } = await getVistaRankingUsuarios({
        page,
        limit: 5,
        nivelComprador: nivel as 'Premium' | 'Gold' | 'Silver' | 'todos'
    });
    
    return (
        <div className="p-6">
            <div className="mb-4">
                <Link href="/Dashboard/Home" className="text-blue-500 hover:underline">
                    ← Volver a reportes
                </Link>
            </div>
            <h1 className="text-2xl font-bold mb-4">Ranking de Usuarios por Gastos</h1>
            <p className="text-gray-600 mb-4">
                Ranking de usuarios ordenado por total gastado con clasificación de nivel (Premium, Gold, Silver).
            </p>
            
            
            {destacado && (
                <div className="bg-gradient-to-r from-green-500 to-emerald-600 text-white rounded-lg p-6 mb-6 shadow-lg">
                    <p className="text-sm uppercase tracking-wide opacity-80">Mayor gasto total</p>
                    <p className="text-4xl font-bold">${Number(destacado.mayorGasto).toFixed(2)}</p>
                    <p className="text-lg mt-1">🏆 {destacado.topComprador} ({destacado.nivelTopComprador})</p>
                    <p className="text-sm opacity-70 mt-2">{destacado.totalUsuarios} usuarios en el ranking</p>
                </div>
            )}
            
            
            <div className="mb-4 flex gap-2 flex-wrap">
                <span className="font-medium">Filtrar por nivel:</span>
                {['todos', 'Premium', 'Gold', 'Silver'].map((n) => (
                    <Link 
                        key={n}
                        href={`/Dashboard/Home/2?nivel=${n}&page=1`}
                        className={`px-3 py-1 rounded ${nivel === n ? 'bg-blue-500 text-white' : 'bg-gray-200 hover:bg-gray-300'}`}
                    >
                        {n}
                    </Link>
                ))}
            </div>
            
            <div className="overflow-x-auto">
                <table className="min-w-full bg-white border border-gray-300">
                    <thead className="bg-gray-100">
                        <tr>
                            <th className="px-4 py-2 border">Ranking</th>
                            <th className="px-4 py-2 border">Usuario</th>
                            <th className="px-4 py-2 border">Total Órdenes</th>
                            <th className="px-4 py-2 border">Gasto Total</th>
                            <th className="px-4 py-2 border">Nivel</th>
                        </tr>
                    </thead>
                    <tbody>
                        {datos.map((row, index) => (
                            <tr key={index} className="hover:bg-gray-50">
                                <td className="px-4 py-2 border text-center">{row.ranking_gastos}</td>
                                <td className="px-4 py-2 border">{row.nombre}</td>
                                <td className="px-4 py-2 border text-center">{row.total_ordenes}</td>
                                <td className="px-4 py-2 border text-right">${Number(row.gasto_total).toFixed(2)}</td>
                                <td className="px-4 py-2 border text-center">
                                    <span className={`px-2 py-1 rounded ${
                                        row.nivel_comprador === 'Premium' ? 'bg-purple-200 text-purple-800' :
                                        row.nivel_comprador === 'Gold' ? 'bg-yellow-200 text-yellow-800' :
                                        'bg-gray-200 text-gray-800'
                                    }`}>
                                        {row.nivel_comprador}
                                    </span>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
            
            <div className="mt-4 flex justify-center gap-2">
                {pagination.page > 1 && (
                    <Link 
                        href={`/Dashboard/Home/2?nivel=${nivel}&page=${pagination.page - 1}`}
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
                        href={`/Dashboard/Home/2?nivel=${nivel}&page=${pagination.page + 1}`}
                        className="px-4 py-2 bg-gray-200 rounded hover:bg-gray-300"
                    >
                        Siguiente
                    </Link>
                )}
            </div>
        </div>
    );
}