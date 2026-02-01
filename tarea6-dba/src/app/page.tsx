import Link from 'next/link'

export default function Home() {
  return (
    <div>
     Esta va a ser la pagina inicial

      <Link href="/reports"
      >ir a reportes</Link>
      
    </div>
    
  );
}
