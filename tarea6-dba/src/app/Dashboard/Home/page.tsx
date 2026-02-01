import React from 'react';
import ReportCard from './ReportCard';
import TopBar from './TopBar';

export default function ReportsPage() {
    return (
        <div className='reports-page'>
            <TopBar />
            <div className='reports-container'>
                <ReportCard 
                    title='Promedio por Categoría' 
                    description='Promedio de precios por categoría de productos' 
                    href='/Dashboard/Home/1' 
                />
                <ReportCard 
                    title='Ranking de Usuarios' 
                    description='Ranking de usuarios por total gastado con clasificación' 
                    href='/Dashboard/Home/2' 
                />
                <ReportCard 
                    title='Órdenes por Status' 
                    description='Distribución de órdenes por estado con porcentajes' 
                    href='/Dashboard/Home/3' 
                />
                <ReportCard 
                    title='Productos Más Vendidos' 
                    description='Ranking de productos más vendidos con ingresos' 
                    href='/Dashboard/Home/4' 
                />
                <ReportCard 
                    title='Desempeño de Usuarios' 
                    description='Análisis de desempeño de usuarios por estado de órdenes' 
                    href='/Dashboard/Home/5' 
                />
            </div>
        </div>
    );
}