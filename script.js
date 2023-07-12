// Efeito para rolagem suave

const links = document.querySelectorAll("nav a");

links.forEach(link => {
  link.addEventListener('click', (event) => {
    event.preventDefault();
    const target = document.querySelector(link.getAttribute('href'));
    const scrollTop = target.getBoundingClientRect().top + window.pageYOffset - 50;
    window.scrollTo({ top: scrollTop, behavior: 'smooth' });
  });
});

const btnToggle = document.querySelector('.btn-toggle');
const menu = document.querySelector('.menu');

btnToggle.addEventListener('click', function() {
  menu.classList.toggle('active');
});

function scrollToTop() {
  var currentScroll = document.documentElement.scrollTop || document.body.scrollTop;
  if (currentScroll > 0) {
    window.requestAnimationFrame(scrollToTop);
    window.scrollTo(0, currentScroll - (currentScroll / 8));
  }
};