// ========== THEME TOGGLE ==========
function toggleTheme() {
    const btn = document.getElementById('themeToggle');
    const isLight = document.body.getAttribute('data-theme') === 'light';

    if (isLight) {
        document.body.removeAttribute('data-theme');
        btn.textContent = '🌙';
        localStorage.setItem('theme', 'dark');
    } else {
        document.body.setAttribute('data-theme', 'light');
        btn.textContent = '☀️';
        localStorage.setItem('theme', 'light');
    }
}

// Load saved theme
(function () {
    const saved = localStorage.getItem('theme');
    const btn = document.getElementById('themeToggle');
    if (saved === 'light') {
        document.body.setAttribute('data-theme', 'light');
        btn.textContent = '☀️';
    }
})();

// ========== SKILLS CAROUSEL ==========
(function () {
    const container = document.querySelector('.skills-container');
    const track = document.getElementById('skillsTrack');
    const grid = document.getElementById('skillsGrid');
    const leftBtn = document.getElementById('skillsLeft');
    const rightBtn = document.getElementById('skillsRight');

    // Duplicate content for infinite scroll
    const originalHTML = grid.innerHTML;
    grid.innerHTML = originalHTML + originalHTML + originalHTML;

    // Set initial position to middle copy
    let singleWidth = grid.scrollWidth / 3;
    let currentX = -singleWidth;
    let prevX = currentX;
    track.style.transform = `translateX(${currentX}px)`;

    function checkBounds() {
        if (currentX > 0) {
            currentX = -singleWidth;
            prevX = currentX;
            track.style.transition = 'none';
            track.style.transform = `translateX(${currentX}px)`;
        } else if (currentX < -singleWidth * 2) {
            currentX = -singleWidth;
            prevX = currentX;
            track.style.transition = 'none';
            track.style.transform = `translateX(${currentX}px)`;
        }
    }

    function scrollBy(amount) {
        track.style.transition = 'transform 0.35s ease';
        currentX += amount;
        prevX = currentX;
        track.style.transform = `translateX(${currentX}px)`;
        setTimeout(checkBounds, 360);
    }

    // Arrow buttons
    leftBtn.addEventListener('click', function () { scrollBy(160); });
    rightBtn.addEventListener('click', function () { scrollBy(-160); });

    // ---- DRAG / TOUCH for horizontal scroll ----
    let isDragging = false;
    let startPos = 0;
    let dragStartX = 0;

    function onDragStart(clientX) {
        isDragging = true;
        startPos = clientX;
        dragStartX = currentX;
        track.style.transition = 'none';
        container.classList.add('dragging');
    }

    function onDragMove(clientX) {
        if (!isDragging) return;
        const diff = clientX - startPos;
        currentX = dragStartX + diff;
        track.style.transform = `translateX(${currentX}px)`;
    }

    function onDragEnd() {
        if (!isDragging) return;
        isDragging = false;
        prevX = currentX;
        container.classList.remove('dragging');
        checkBounds();
    }

    // Mouse events (desktop drag)
    container.addEventListener('mousedown', function (e) {
        e.preventDefault();
        onDragStart(e.clientX);
    });

    document.addEventListener('mousemove', function (e) {
        if (isDragging) {
            e.preventDefault();
            onDragMove(e.clientX);
        }
    });

    document.addEventListener('mouseup', onDragEnd);

    // Touch events (mobile swipe)
    container.addEventListener('touchstart', function (e) {
        onDragStart(e.touches[0].clientX);
    }, { passive: true });

    container.addEventListener('touchmove', function (e) {
        onDragMove(e.touches[0].clientX);
    }, { passive: true });

    container.addEventListener('touchend', onDragEnd, { passive: true });

    // Recalculate on resize
    window.addEventListener('resize', function () {
        singleWidth = grid.scrollWidth / 3;
        currentX = -singleWidth;
        prevX = currentX;
        track.style.transition = 'none';
        track.style.transform = `translateX(${currentX}px)`;
    });
})();

// ========== MODAL ==========
function openModal(card) {
    const modal = document.getElementById('modal');
    const modalBody = document.getElementById('modal-body');

    const title = card.querySelector('.project-title').textContent;
    const date = card.querySelector('.project-date').textContent;
    const desc = card.querySelector('.project-desc').textContent;
    const tagsContainer = card.querySelector('.project-tags');
    const details = card.querySelector('.project-details');
    const repo = card.getAttribute('data-repo') || '';

    // Build tags HTML
    let tagsHTML = '';
    if (tagsContainer) {
        const tags = tagsContainer.querySelectorAll('.tag');
        tagsHTML = Array.from(tags).map(t => `<span class="tag">${t.textContent}</span>`).join('');
    }

    // Build sections HTML from project-details
    let sectionsHTML = '';
    if (details) {
        const sections = details.querySelectorAll('.project-section');
        const items = [];
        sections.forEach(function (sec) {
            const label = sec.querySelector('.project-section-label');
            const content = sec.querySelector('.project-section-content');
            if (label && content) {
                items.push(`
                    <div class="modal-section">
                        <p class="modal-section-label">${label.textContent}</p>
                        <p class="modal-section-content">${content.textContent}</p>
                    </div>`);
            }
        });
        if (items.length) {
            sectionsHTML = `<div class="modal-sections-wrapper">${items.join('')}</div>`;
        }
    }

    // Build GitHub link
    let repoHTML = '';
    if (repo) {
        repoHTML = `
            <a href="${repo}" target="_blank" rel="noopener noreferrer" class="modal-repo-link" onclick="event.stopPropagation()">
                <svg viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                </svg>
                Ver repositorio en GitHub
            </a>`;
    }

    modalBody.innerHTML = `
        <div class="modal-header">
            <div class="modal-header-left">
                <h3 class="modal-title">${title}</h3>
            </div>
            <span class="modal-date">${date}</span>
        </div>
        <p class="modal-body-desc">${desc}</p>
        ${sectionsHTML}
        ${repoHTML}
        <div class="modal-tags">${tagsHTML}</div>
    `;

    // Lock body scroll
    const scrollY = window.scrollY;
    document.body.style.position = 'fixed';
    document.body.style.top = `-${scrollY}px`;
    document.body.style.width = '100%';
    document.body.style.overflow = 'hidden';

    modal.classList.add('active');
}

function closeModal(event) {
    // If called from overlay click, only close if clicking overlay itself
    if (event && event.target && event.target !== document.getElementById('modal')) return;

    const modal = document.getElementById('modal');
    const scrollY = document.body.style.top;

    modal.classList.remove('active');

    // Restore body scroll
    document.body.style.position = '';
    document.body.style.top = '';
    document.body.style.width = '';
    document.body.style.overflow = '';
    window.scrollTo(0, parseInt(scrollY || '0') * -1);
}

// Close with Escape
document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
        const modal = document.getElementById('modal');
        if (modal.classList.contains('active')) {
            closeModal();
        }
    }
});
