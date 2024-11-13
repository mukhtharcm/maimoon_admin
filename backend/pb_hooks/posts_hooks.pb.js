onRecordBeforeCreateRequest((e) => {
    const { collection, record } = e;

    // Only run this hook for the posts collection
    if (collection.name !== 'posts') {
        return;
    }

    // Get the series ID from the record
    const seriesId = record.get('series');

    if (!seriesId) {
        record.set('order', 1); // Start with order 1 for posts without series
        return;
    }

    // Find the highest order number in the same series
    const posts = $app.dao().findRecordsByFilter(
        'posts',
        `series = '${seriesId}'`,
        '-order', // Sort by order descending
        1,        // Limit to 1 record
    );

    let nextOrder = 1; // Start with order 1
    if (posts.length > 0) {
        const lastPost = posts[0];
        nextOrder = lastPost.get('order') + 1;
    }

    // Set the new order
    record.set('order', nextOrder);
});     