document.addEventListener('DOMContentLoaded', () => {
    const menuToggle = document.getElementById('menu-toggle');
    const mobileMenu = document.getElementById('mobile-menu');
    const menuIcon = document.getElementById('menu-icon');
    const sections = [...document.querySelectorAll('section[id]')];
    const desktopLinks = [...document.querySelectorAll('.nav-link')];
    const mobileLinks = [...document.querySelectorAll('.mobile-nav-link')];
    const revealItems = document.querySelectorAll('.reveal');
    const progressBars = document.querySelectorAll('.progress-bar-fill');

    const setMenuIcon = (isOpen) => {
        if (!menuIcon) {
            return;
        }

        menuIcon.innerHTML = isOpen
            ? '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />'
            : '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />';
    };

    const setMenuState = (isOpen) => {
        if (!menuToggle || !mobileMenu) {
            return;
        }

        mobileMenu.classList.toggle('hidden', !isOpen);
        menuToggle.setAttribute('aria-expanded', String(isOpen));
        menuToggle.setAttribute('aria-label', isOpen ? 'Fechar menu' : 'Abrir menu');
        setMenuIcon(isOpen);
    };

    if (menuToggle && mobileMenu) {
        menuToggle.addEventListener('click', (event) => {
            event.stopPropagation();
            const isOpen = mobileMenu.classList.contains('hidden');
            setMenuState(isOpen);
        });

        mobileLinks.forEach((link) => {
            link.addEventListener('click', () => setMenuState(false));
        });

        document.addEventListener('click', (event) => {
            if (!mobileMenu.contains(event.target) && !menuToggle.contains(event.target)) {
                setMenuState(false);
            }
        });

        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') {
                setMenuState(false);
            }
        });
    }

    const setActiveLink = () => {
        const scrollPosition = window.scrollY + 180;
        let currentId = sections[0]?.id || '';

        sections.forEach((section) => {
            if (scrollPosition >= section.offsetTop) {
                currentId = section.id;
            }
        });

        [...desktopLinks, ...mobileLinks].forEach((link) => {
            const isActive = link.getAttribute('href') === `#${currentId}`;
            link.classList.toggle('is-active', isActive);
            link.setAttribute('aria-current', isActive ? 'page' : 'false');
        });
    };

    if (sections.length) {
        setActiveLink();
        window.addEventListener('scroll', setActiveLink, { passive: true });
    }

    if ('IntersectionObserver' in window) {
        const revealObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach((entry) => {
                if (!entry.isIntersecting) {
                    return;
                }

                entry.target.classList.add('is-visible');
                observer.unobserve(entry.target);
            });
        }, { threshold: 0.15 });

        revealItems.forEach((item) => revealObserver.observe(item));

        const skillObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach((entry) => {
                if (!entry.isIntersecting) {
                    return;
                }

                const targetWidth = entry.target.dataset.width || '0%';
                entry.target.style.width = targetWidth;
                observer.unobserve(entry.target);
            });
        }, { threshold: 0.4 });

        progressBars.forEach((bar) => skillObserver.observe(bar));
    } else {
        revealItems.forEach((item) => item.classList.add('is-visible'));
        progressBars.forEach((bar) => {
            bar.style.width = bar.dataset.width || '0%';
        });
    }
});