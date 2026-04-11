<!DOCTYPE html>
<html lang="pt-BR" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daniel Torres | Desenvolvedor Full-Stack</title>
    <meta name="description" content="Portfólio de Daniel Torres, desenvolvedor full-stack com experiência em PHP, CodeIgniter, JavaScript, MySQL, APIs REST e manutenção de sistemas web.">
    <meta name="theme-color" content="#060e20">
    <meta name="author" content="Daniel Torres">
    <meta property="og:title" content="Daniel Torres | Desenvolvedor Full-Stack">
    <meta property="og:description" content="Portfólio profissional com experiência, habilidades e canais de contato de Daniel Torres.">
    <meta property="og:type" content="website">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                        headline: ['Space Grotesk', 'sans-serif'],
                    },
                    colors: {
                        primary: '#81ecff',
                        'primary-dim': '#00d4ec',
                        tertiary: '#70aaff',
                        background: '#060e20',
                        surface: '#060e20',
                        'surface-container': '#0f1930',
                        'surface-container-high': '#141f38',
                        'surface-container-highest': '#192540',
                        'on-surface': '#dee5ff',
                        'on-surface-variant': '#a3aac4',
                        'outline-variant': '#40485d',
                        success: '#34d399',
                        warning: '#fbbf24',
                    }
                }
            }
        };
    </script>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body class="bg-background text-on-surface font-sans antialiased overflow-x-hidden selection:bg-primary/20 selection:text-on-surface">
    <a href="#home" class="skip-link">Pular para o conteúdo</a>

    <header class="fixed top-0 w-full z-50 bg-[#060e20]/90 backdrop-blur-xl border-b border-outline-variant/10">
        <div class="flex justify-between items-center px-6 py-4 max-w-7xl mx-auto">
            <a href="#home" class="flex items-center gap-3 group" aria-label="Ir para o início do portfólio">
                <span class="w-10 h-10 rounded-xl bg-primary/10 border border-primary/20 flex items-center justify-center text-primary font-headline font-bold">DT</span>
                <div>
                    <span class="block text-base md:text-lg font-bold tracking-tight text-on-surface font-headline">DANIEL TORRES</span>
                    <span class="block text-[10px] uppercase tracking-[0.3em] text-on-surface-variant">Full-Stack Developer</span>
                </div>
            </a>

            <nav class="hidden lg:flex gap-8 items-center" aria-label="Navegação principal">
                <a href="#home" class="nav-link text-sm uppercase tracking-widest text-on-surface-variant hover:text-primary transition-all">Início</a>
                <a href="#about" class="nav-link text-sm uppercase tracking-widest text-on-surface-variant hover:text-primary transition-all">Sobre</a>
                <a href="#experience" class="nav-link text-sm uppercase tracking-widest text-on-surface-variant hover:text-primary transition-all">Experiência</a>
                <a href="#skills" class="nav-link text-sm uppercase tracking-widest text-on-surface-variant hover:text-primary transition-all">Habilidades</a>
                <a href="#contact" class="nav-link text-sm uppercase tracking-widest text-on-surface-variant hover:text-primary transition-all">Contato</a>
                <a href="https://www.linkedin.com/in/daniel-torres-0851581a0/" target="_blank" rel="noreferrer" class="ml-4 px-6 py-2 bg-primary text-background font-bold rounded-lg hover:scale-105 transition-all focus:outline-none focus:ring-2 focus:ring-primary">
                    LinkedIn
                </a>
            </nav>

            <button id="menu-toggle" class="lg:hidden text-primary p-2 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary" aria-controls="mobile-menu" aria-expanded="false" aria-label="Abrir menu">
                <svg id="menu-icon" xmlns="http://www.w3.org/2000/svg" class="w-7 h-7" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
                </svg>
            </button>
        </div>

        <div id="mobile-menu" class="hidden lg:hidden absolute top-full left-0 w-full bg-surface-container border-b border-outline-variant/20 shadow-2xl">
            <nav class="flex flex-col p-6 gap-4" aria-label="Navegação mobile">
                <a href="#home" class="mobile-nav-link text-lg font-headline uppercase tracking-widest py-3 border-b border-outline-variant/10 text-primary">Início</a>
                <a href="#about" class="mobile-nav-link text-lg font-headline uppercase tracking-widest py-3 border-b border-outline-variant/10">Sobre</a>
                <a href="#experience" class="mobile-nav-link text-lg font-headline uppercase tracking-widest py-3 border-b border-outline-variant/10">Experiência</a>
                <a href="#skills" class="mobile-nav-link text-lg font-headline uppercase tracking-widest py-3 border-b border-outline-variant/10">Habilidades</a>
                <a href="#contact" class="mobile-nav-link text-lg font-headline uppercase tracking-widest py-3 border-b border-outline-variant/10">Contato</a>
                <a href="https://github.com/devdanieltorres" target="_blank" rel="noreferrer" class="w-full mt-4 px-6 py-4 bg-primary text-background font-bold rounded-xl text-center">
                    Ver GitHub
                </a>
            </nav>
        </div>
    </header>