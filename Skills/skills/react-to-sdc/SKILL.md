---
name: react-to-sdc
description: Convert a React component to a Drupal SDC
disable-model-invocation: true
---

# React to SDC

Convert a React component to a Drupal SDC (single directory component).

## Instructions

The `$ARGUMENT` is the React component to be converted. This can be an also be attachment in context. Follow the steps below to convert it to a Drupal SDC. Always reference the repository's instructions file for any specific requirements or guidelines related to SDC creation and structure. If any instructions conflict with the steps below, follow the repository's instructions.

### Phase 1 - Folder Creation:

Create the SDC folder. Reference the instructions file of the repository to determine the location to save the conversion. Create a new folder with the name of the component in that location.

### Phase 2 - Create the component's yml file:

1. Use the components jsx to create the component twig file
2. Use the components props, react context or any other variables in the template to Create the Component yml's file. Name the file with the name of the component and the extension component.yml (e.g., `$ARGUMENT.component.yml`, `dashboard-resource-listing.component.yml`, etc.)
3. Use the components Children as slots

EXAMPLE:

```yaml
name: Dashboard Resource Listing
description: "Dashboard component for displaying latest resources with optional featured resource. Per MIWHNDB-116."
props:
  type: object
  properties:
    dashboard_resource_listing_heading:
      type: string
      title: Heading
      description: "Optional heading text for the resource list section."
      examples:
        - Latest Articles and Member Content
    dashboard_resource_listing_see_all_link:
      type: string
      title: See All Link
      description: 'URL for the "See All" link to Resource Hub.'
      examples:
        - /resources
    dashboard_resource_listing_featured_resource:
      type: object
      title: Featured Resource
      description: "Optional featured resource to display first, outlined in blue."
      properties:
        title:
          type: string
          title: Title
          description: "The resource title (H1)"
        summary:
          type: string
          title: Summary
          description: "The resource summary text"
        thumbnail:
          type: string
          title: Thumbnail
          description: "The resource thumbnail image markup"
        link:
          type: string
          title: Link
          description: "URL to the resource detail page"
slots:
  dashboard_resource_listing_view:
    type: any
    description: Slot for the resource list view (excludes featured resource).
```

### Phase 3: Create the component's twig file

convert the jsx to twig and save it in the same folder as the yml file. The file should be named with the name of the component and the extension .twig, (e.g., `$ARGUMENT.twig`, `dashboard-resource-listing.twig`, etc.)

### Phase 4: Create the component's css file

1. Determine if the component is using tailwinds or custom css
2. Let the user know which is being used
3. **If the repository's instructions don't specify which to use, ask the user which they want to use.**

- **if using tailswinds** ask if they want to
  - leave as is
  - convert to BEM (reference any instructions in the repository about css structure and naming conventions)
  - something else
- **if using custom css**
  - ask if it should be converted to Tailwinds

- **if user chooses to convert tailwind to BEM**:
  - create a file named with the name of the component and the extension .css (e.g., `$ARGUMENT.css`, `dashboard-resource-listing.css`, etc.)
  - save it in the same folder as the yml and twig files
  - keep the css flat as possible.
  - nesting for psuedo elements, focus, hover and media queries is OK but otherwise avoid.
  - avoid using `&__`.
    - EXAMPLES:
      - ❌

      ```css
      .dashboard-resource-listing {
        text-align: left;

        &__featured-resource {
          border: 1px solid blue;
        }
      }
      ```

      - ✅

      ```css
      .dashboard-resource-listing {
        text-align: left;
      }

      .dashboard-resource-listing__featured-resource {
        border: 1px solid blue;
      }
      ```

## Phase 5: Create the component's JS file

1. Analyse if there any interactions or dynamic behavior in the component. If none, skip this phase. The skill has been completed.
2. Analyse if any libraries or modules are being imported. If NO libraries or modules are being imported, create a file named with the name of the component and the extension .js (e.g.,`dashboard-resource-listing.js`, etc.) and save it in the same folder as the yml and twig files. Convert any React logic to vanilla js and add it to the file inside a Drupal behavior named to match the component.

EXAMPLE:

```javascript
(({ behaviors }) => {
  behaviors.componentName = {
    attach: context => {
      const components = once('component-name', '.component-name', context);

      if (!components.length) {
        return;
      }

      components.forEach(component => {
        const items = component.querySelectorAll('.component__item');

        items.forEach((item, index) => {
          const trigger = item.querySelector('.component__trigger');
          const content = item.querySelector('.component__content');
          const itemId = item.id;

          if (trigger && content) {
            // Set initial ARIA states
            trigger.setAttribute('tabindex', '0');
            trigger.setAttribute('aria-expanded',
              item.classList.contains('active') ? 'true' : 'false'
            );

            // Handle interactions
            trigger.addEventListener('click', (event) => {
              // Update URL if needed
              if (itemId) {
                history.pushState({}, "", `#${itemId}`);
              }

              // Toggle states
              const isExpanded = trigger.getAttribute('aria-expanded') === 'true';
              trigger.setAttribute('aria-expanded', !isExpanded);
              item.classList.toggle('active');

              // Handle other items if exclusive behavior
              items.forEach(otherItem => {
                if (otherItem !== item) {
                  otherItem.classList.remove('active');
                  const otherTrigger = otherItem.querySelector('.component__trigger');
                  if (otherTrigger) {
                    otherTrigger.setAttribute('aria-expanded', 'false');
                  }
                }
              });
            });

            // Keyboard support
            trigger.addEventListener('keydown', (event) => {
              if (event.key === 'Enter' || event.key === ' ') {
                event.preventDefault();
                trigger.click();
              }
            });
          }
        });
      };
    }
  };
})(Drupal);
```

3. If libraries or modules are being imported, create a file name with the name of the component with `init.js` as the extension (e.g., `dashboard-resource-listing.init.js`, etc.) and save it in the same folder as the yml and twig files.

- Convert any React logic to vanilla js.
- Let the user know if any of the imports are React specific and ask how they want to proceed with those.
- Wrap the js from the component being converted in a function named to match the component (e.g., `initFactsSlider`) and export it as default. NOTE: the <el> is the element that the <js-component-name> class is placed on.

EXAMPLE:

```javascript
const initFactSlider = (el, i) => {
  const imageCarousel = new Swiper(el, {
    modules: [A11y, Navigation, Pagination, Keyboard],
    slidesPerView: 1,
    allowTouchMove: false,
    autoHeight: true,
    keyboard: { enabled: true, onlyInViewport: true },
    loop: true,
    navigation: {
      nextEl: ".image-carousel__next",
      prevEl: ".image-carousel__prev",
    },
    pagination: {
      el: ".image-carousel__pagination",
      clickable: true,
    },
    on: {
      init: function () {
        updateNavigationOffset(this);
      },
      slideChange: function () {
        updateNavigationOffset(this);
      },
    },
  });
};

export default initFactSlider;
```

4. Analyse the `index.js` file of the repository to see if using the dynamic importer pattern, if so

- add a selector class to the outermost element of the component's twig file with the format `js-[component-name]` (e.g., `js-image-carousel`, etc.)
- add an entry to the dynamic importer with the component's selector and js file path.
  EXAMPLE

```javascript
dynamicRenderer([
  /* PLOP_INDEX_IMPORT */
  {
    selector: ".js-image-carousel",
    name: "components/image-carousel/image-carousel.init.js",
  },
  {
    selector: ".js-member-directory",
    name: "apps/components/MemberDirectory/MemberDirectory.render.jsx",
  },
  {
    selector: ".js-site-search",
    name: "apps/components/Search/Search.render.jsx",
  },
]);
```
