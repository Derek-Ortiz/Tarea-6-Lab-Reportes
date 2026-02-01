import React from 'react';
import ReportCard from './ReportCard';
import TopBar from './TopBar';

export default function ReportsPage() {
    return (
        <div className='reports-page'>
            <TopBar />
            <div className='reports-container'>
                <ReportCard title='Reporte 1' description='Descripción del Reporte 1' href='/Dashboard/Home/1' />
                <ReportCard title='Reporte 2' description='Descripción del Reporte 2' href='/Dashboard/Home/2' />
                <ReportCard title='Reporte 3' description='Descripción del Reporte 3' href='/Dashboard/Home/3' />
                <ReportCard title='Reporte 4' description='Descripción del Reporte 4' href='/Dashboard/Home/4' />
                <ReportCard title='Reporte 5' description='Descripción del Reporte 5' href='/Dashboard/Home/5' />
            </div>
        </div>
    );
}