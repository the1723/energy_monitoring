// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import "basecoat-css/all"
import "chartkick/chart.js"
// View transitions for turbo frame navigation
addEventListener("turbo:before-frame-render", (event) => {
    if (document.startViewTransition) {
        const originalRender = event.detail.render
        event.detail.render = async (currentElement, newElement) => {
            const transition = document.startViewTransition(() => originalRender(currentElement, newElement))
            await transition.finished
        }
    }
})
