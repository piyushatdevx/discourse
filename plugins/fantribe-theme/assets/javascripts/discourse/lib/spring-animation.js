/**
 * Spring Animation Helper — JS-based spring physics
 * Matches Framer Motion: { type: 'spring', damping: 25, stiffness: 300 }
 *
 * Uses requestAnimationFrame for smooth 60fps animation.
 * NOT a cubic-bezier approximation — this is real spring physics.
 *
 * @param {HTMLElement} element - The element to animate
 * @param {Object} from - Starting property values { opacity, scale, x, y }
 * @param {Object} to - Target property values { opacity, scale, x, y }
 * @param {Object} [options] - Spring configuration
 * @param {number} [options.damping=25] - Damping ratio
 * @param {number} [options.stiffness=300] - Spring stiffness
 * @param {number} [options.mass=1] - Mass
 * @param {Function} [options.onComplete] - Callback when animation completes
 * @returns {{ cancel: Function }} - Cancel handle
 */
export function springAnimate(element, from, to, options = {}) {
  const { damping = 25, stiffness = 300, mass = 1, onComplete } = options;

  // Track per-property state
  const properties = Object.keys(to);
  const state = {};

  properties.forEach((prop) => {
    state[prop] = {
      current: from[prop] ?? to[prop],
      velocity: 0,
      target: to[prop],
    };
  });

  let rafId = null;
  let lastTime = null;

  function applyTransform() {
    const opacity = state.opacity?.current ?? 1;
    const scale = state.scale?.current ?? 1;
    const x = state.x?.current ?? 0;
    const y = state.y?.current ?? 0;

    if (state.opacity) {
      element.style.opacity = opacity;
    }

    const transforms = [];
    if (state.x || state.y) {
      transforms.push(`translate(${x}px, ${y}px)`);
    }
    if (state.scale) {
      transforms.push(`scale(${scale})`);
    }
    if (transforms.length > 0) {
      element.style.transform = transforms.join(" ");
    }
  }

  function step(timestamp) {
    if (lastTime === null) {
      lastTime = timestamp;
      applyTransform();
      rafId = requestAnimationFrame(step);
      return;
    }

    // dt in seconds, cap at 1/30s to avoid instability
    const dt = Math.min((timestamp - lastTime) / 1000, 1 / 30);
    lastTime = timestamp;

    let allSettled = true;

    properties.forEach((prop) => {
      const s = state[prop];
      const displacement = s.current - s.target;

      // Spring force: F = -k * x - d * v
      const springForce = -stiffness * displacement;
      const dampingForce = -damping * s.velocity;
      const acceleration = (springForce + dampingForce) / mass;

      s.velocity += acceleration * dt;
      s.current += s.velocity * dt;

      // Check convergence: within 0.001 of target and velocity near zero
      if (Math.abs(displacement) > 0.001 || Math.abs(s.velocity) > 0.01) {
        allSettled = false;
      }
    });

    if (allSettled) {
      // Snap to final values
      properties.forEach((prop) => {
        state[prop].current = state[prop].target;
      });
      applyTransform();
      if (onComplete) {
        onComplete();
      }
      return;
    }

    applyTransform();
    rafId = requestAnimationFrame(step);
  }

  // Start animation
  applyTransform();
  rafId = requestAnimationFrame(step);

  return {
    cancel() {
      if (rafId) {
        cancelAnimationFrame(rafId);
        rafId = null;
      }
    },
  };
}

/**
 * Convenience: animate modal entrance
 * Spec §3.6: initial { opacity: 0, scale: 0.95 } → animate { opacity: 1, scale: 1 }
 */
export function animateModalIn(element, onComplete) {
  return springAnimate(
    element,
    { opacity: 0, scale: 0.95 },
    { opacity: 1, scale: 1 },
    { damping: 25, stiffness: 300, onComplete }
  );
}

/**
 * Convenience: animate modal exit
 * Spec §3.6: exit { opacity: 0, scale: 0.95 }
 */
export function animateModalOut(element, onComplete) {
  return springAnimate(
    element,
    { opacity: 1, scale: 1 },
    { opacity: 0, scale: 0.95 },
    { damping: 25, stiffness: 300, onComplete }
  );
}
