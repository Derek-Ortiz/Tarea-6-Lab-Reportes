import { getVistaAnalisisDesempeno } from "@/app/actions/reportes";
import Link from "next/link";

export default async function Report5Page({
    searchParams
}: {
    searchParams: Promise<{ clasificacion?: string }>
}) {
    const params = await searchParams;
    const clasificacion = params.clasificacion || 'todos';
    
    const { data: datos, destacado } = await getVistaAnalisisDesempeno({
        clasificacion: clasificacion as 'Cliente Activo' | 'Cliente Inactivo' | 'todos'
    });
    
    return (
        <div className="p-6">
            <div className="mb-4">
                <Link href="/Dashboard/Home" className="text-blue-500 hover:underline">
                    ← Volver a reportes
                </Link>
            </div>
            <h1 className="text-2xl font-bold mb-4">Análisis de Desempeño de Usuarios</h1>
            <p className="text-gray-600 mb-4">
                Análisis detallado del desempeño de usuarios mostrando órdenes entregadas, canceladas y monto acumulado.
            </p>
            
            
            {destacado && (
                <div className="bg-teal-50 border-l-4 border-teal-500 p-4 mb-6">
                    <h3 className="font-bold text-teal-800">📊 Dato Destacado</h3>
                    <p className="text-teal-700">
                        Tasa de éxito (órdenes entregadas vs canceladas): <strong>{destacado.tasaExito}</strong>
                    </p>
                    <p className="text-teal-600 text-sm">
                        Clientes activos: {destacado.clientesActivos} | 
                        Clientes inactivos: {destacado.clientesInactivos} |
                        Órdenes entregadas: {destacado.totalOrdenesEntregadas} |
                        Órdenes canceladas: {destacado.totalOrdenesCanceladas}
                    </p>
                </div>
            )}
            
            <div className="mb-4 flex gap-2 flex-wrap">
                <span className="font-medium">Filtrar por clasificación:</span>
                {['todos', 'Cliente Activo', 'Cliente Inactivo'].map((c) => (
                    <Link 
                        key={c}
                        href={`/Dashboard/Home/5?clasificacion=${encodeURIComponent(c)}`}
                        className={`px-3 py-1 rounded ${clasificacion === c ? 'bg-teal-500 text-white' : 'bg-gray-200 hover:bg-gray-300'}`}
                    >
                        {c}
                    </Link>
                ))}
            </div>
            
            <div className="overflow-x-auto">
                <table className="min-w-full bg-white border border-gray-300">
                    <thead className="bg-gray-100">
                        <tr>
                            <th className="px-4 py-2 border">Usuario</th>
                            <th className="px-4 py-2 border">Órdenes Entregadas</th>
                            <th className="px-4 py-2 border">Órdenes Canceladas</th>
                            <th className="px-4 py-2 border">Monto Total</th>
                            <th className="px-4 py-2 border">Monto Acumulado</th>
                            <th className="px-4 py-2 border">Clasificación</th>
                        </tr>
                    </thead>
                    <tbody>
                        {datos.map((row, index) => (
                            <tr key={index} className="hover:bg-gray-50">
                                <td className="px-4 py-2 border">{row.nombre}</td>
                                <td className="px-4 py-2 border text-center">{row.ordenes_entregadas}</td>
                                <td className="px-4 py-2 border text-center">{row.ordenes_canceladas}</td>
                                <td className="px-4 py-2 border text-right">${Number(row.monto_total).toFixed(2)}</td>
                                <td className="px-4 py-2 border text-right">${Number(row.monto_acumulado).toFixed(2)}</td>
                                <td className="px-4 py-2 border text-center">
                                    <span className={`px-2 py-1 rounded ${
                                        row.clasificacion === 'Cliente Activo' ? 'bg-green-200 text-green-800' : 'bg-gray-200 text-gray-800'
                                    }`}>
                                        {row.clasificacion}
                                    </span>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}