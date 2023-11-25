// app/GoogleBooksAPIs.js
const searchBooks = async (query) => {
  const endpoint = 'https://www.googleapis.com/books/v1';
  const res = await fetch(`${endpoint}/volumes?q=${query}`);
  const data = await res.json();

  const items = data.items.map(item => {
    const vi = item.volumeInfo;
    return {
      title: vi.title,
      description: vi.description,
      link: vi.infoLink,
      image: vi.imageLinks ? vi.imageLinks.smallThumbnail : '',
    };
  });

  return items;
};

export default searchBooks;
