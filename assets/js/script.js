document.addEventListener('DOMContentLoaded', () => {
    const menuToggle = document.getElementById('menu-toggle');
    const mobileMenu = document.getElementById('mobile-menu');
    const menuIcon = document.getElementById('menu-icon');
    const sections = [...document.querySelectorAll('section[id]')];
    const desktopLinks = [...document.querySelectorAll('.nav-link')];
    const mobileLinks = [...document.querySelectorAll('.mobile-nav-link')];
    const revealItems = document.querySelectorAll('.reveal');
    const progressBars = document.querySelectorAll('.progress-bar-fill');
    const fullscreenTriggers = [...document.querySelectorAll('[data-fullscreen-trigger]')];
    const lightbox = document.querySelector('[data-lightbox]');
    const lightboxImage = lightbox?.querySelector('[data-lightbox-image]') || null;
    const lightboxCaption = lightbox?.querySelector('[data-lightbox-caption]') || null;
    const lightboxClose = lightbox?.querySelector('[data-lightbox-close]') || null;

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

    const openLightbox = (trigger) => {
        if (!lightbox || !lightboxImage) {
            return;
        }

        const imageSrc = trigger.getAttribute('data-image-src');
        const imageAlt = trigger.getAttribute('data-image-alt') || '';
        const imageCaption = trigger.getAttribute('data-image-caption') || '';

        if (!imageSrc) {
            return;
        }

        lightboxImage.src = imageSrc;
        lightboxImage.alt = imageAlt;

        if (lightboxCaption) {
            lightboxCaption.textContent = imageCaption;
        }

        lightbox.classList.remove('hidden');
        requestAnimationFrame(() => lightbox.classList.add('is-open'));
        document.body.style.overflow = 'hidden';
    };

    const closeLightbox = () => {
        if (!lightbox || !lightboxImage) {
            return;
        }

        lightbox.classList.remove('is-open');
        document.body.style.overflow = '';

        window.setTimeout(() => {
            if (lightbox.classList.contains('is-open')) {
                return;
            }

            lightbox.classList.add('hidden');
            lightboxImage.src = '';
            lightboxImage.alt = '';

            if (lightboxCaption) {
                lightboxCaption.textContent = '';
            }
        }, 200);
    };

    fullscreenTriggers.forEach((trigger) => {
        trigger.addEventListener('click', () => openLightbox(trigger));
    });

    if (lightbox) {
        lightbox.addEventListener('click', (event) => {
            if (event.target === lightbox) {
                closeLightbox();
            }
        });
    }

    if (lightboxClose) {
        lightboxClose.addEventListener('click', closeLightbox);
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

    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') {
            closeLightbox();
        }
    });
});