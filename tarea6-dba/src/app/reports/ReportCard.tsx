import React from 'react';
import Link from 'next/link';
import './ReportCard.css';

type ReportCardProps = {
    title: string;
    description: string;
    href: string;
};

const ReportCard = ({ title, description, href }: ReportCardProps) => {
    return (
        <Link href={href} className="report-card">
            <h2>{title}</h2>
            <p>{description}</p>
        </Link>
    );
};

export default ReportCard;