import { getVistaOrdenesPorStatus } from "@/app/actions/reportes";
import Link from "next/link";

export default async function Report3Page() {
    const { data: datos, destacado } = await getVistaOrdenesPorStatus();
    
    return (
        <div className="p-6">
            <div className="mb-4">
                <Link href="/Dashboard/Home" className="text-blue-500 hover:underline">
                    ← Volver a reportes
                </Link>
            </div>
            <h1 className="text-2xl font-bold mb-4">Órdenes por Status</h1>
            <p className="text-gray-600 mb-4">
                Distribución de órdenes por estado mostrando cantidad, monto total y porcentaje de distribución.
            </p>
            
            {/* KPI Destacado */}
            {destacado && (
                <div className="bg-gradient-to-r from-orange-500 to-amber-500 text-white rounded-lg p-6 mb-6 shadow-lg">
                    <p className="text-sm uppercase tracking-wide opacity-80">Status más frecuente</p>
                    <p className="text-4xl font-bold">{destacado.porcentajeStatusMasComun}%</p>
                    <p className="text-lg mt-1 capitalize">📦 {destacado.statusMasComun}</p>
                    <p className="text-sm opacity-70 mt-2">{destacado.totalOrdenes} órdenes | ${destacado.montoTotalGeneral} total</p>
                </div>
            )}
            
            <div className="overflow-x-auto">
                <table className="min-w-full bg-white border border-gray-300">
                    <thead className="bg-gray-100">
                        <tr>
                            <th className="px-4 py-2 border">Status</th>
                            <th className="px-4 py-2 border">Cantidad Órdenes</th>
                            <th className="px-4 py-2 border">Monto Total</th>
                            <th className="px-4 py-2 border">% Distribución</th>
                        </tr>
                    </thead>
                    <tbody>
                        {datos.map((row, index) => (
                            <tr key={index} className="hover:bg-gray-50">
                                <td className="px-4 py-2 border">
                                    <span className={`px-2 py-1 rounded capitalize ${
                                        row.status === 'entregado' ? 'bg-green-200 text-green-800' :
                                        row.status === 'enviado' ? 'bg-blue-200 text-blue-800' :
                                        row.status === 'pagado' ? 'bg-yellow-200 text-yellow-800' :
                                        row.status === 'pendiente' ? 'bg-orange-200 text-orange-800' :
                                        'bg-red-200 text-red-800'
                                    }`}>
                                        {row.status}
                                    </span>
                                </td>
                                <td className="px-4 py-2 border text-center">{row.cantidad_ordenes}</td>
                                <td className="px-4 py-2 border text-right">${Number(row.monto_total).toFixed(2)}</td>
                                <td className="px-4 py-2 border text-center">{row.porcentaje_distribucion}%</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}