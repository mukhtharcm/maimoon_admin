onRecordBeforeCreateRequest(async (e) => {
    const { collection, record } = e;

    // Only run this hook for the tags collection
    if (collection.name !== 'tags') {
        return;
    }

    // Get the name from the record
    const name = record.get('name');

    if (!name) {
        return;
    }

    // Generate base slug from name
    let slug = name
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-') // Replace non-alphanumeric chars with hyphen
        .replace(/^-+|-+$/g, '')     // Remove leading/trailing hyphens
        .trim();

    // Check if slug exists
    const existingTags = await $app.dao().findRecordsByFilter(
        'tags',
        `slug = '${slug}'`,
    );

    // If slug exists, append random string
    if (existingTags.length > 0) {
        const randomString = Math.random().toString(36).substring(2, 7);
        slug = `${slug}-${randomString}`;
    }

    // Set the slug
    record.set('slug', slug);
}); 