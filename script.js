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

// Envio email

const form = document.getElementById("contact-form");

form.addEventListener("submit", function(event) {
  event.preventDefault();
  const name = document.getElementById("name").value;
  const email = document.getElementById("email").value;
  const subject = document.getElementById("subject").value;
  const message = document.getElementById("message").value;

  const data = {
    name,
    email,
    subject,
    message,
  };

  fetch("send-email.php", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(data)
  })
  .then(response => {
    alert("Mensagem enviada com sucesso!");
    form.reset();
  })
  .catch(error => {
    console.error(error);
    alert("Ocorreu um erro ao enviar a mensagem.");
  });
});

function scrollToTop() {
  var currentScroll = document.documentElement.scrollTop || document.body.scrollTop;
  if (currentScroll > 0) {
    window.requestAnimationFrame(scrollToTop);
    window.scrollTo(0, currentScroll - (currentScroll / 8));
  }
};