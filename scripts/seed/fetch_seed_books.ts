import { writeFileSync } from "node:fs";

const QUERIES = [
  "Astrid Lindgren",
  "Tove Jansson",
  "Gunilla Bergström",
  "Sven Nordqvist",
  "Martin Widmark",
  "Elsa Beskow",
  "Harry Potter",
  "Ilon Wikland",
  "Barbro Lindgren",
  "Pernilla Stalfelt",
  "Lena Anderson",
  "Elias Våhlund",
  "Inger Sandberg",
  "Ulf Nilsson"
];

interface Book {
  isbn: string;
  title: string;
  author: string;
  coverUrl?: string;
}

async function fetchBooks(): Promise<void> {
  const books: Book[] = [];
  const seenIsbns = new Set<string>();

  for (const query of QUERIES) {
    console.log(`Fetching ${query}...`);
    const url = `https://openlibrary.org/search.json?q=${encodeURIComponent(query)}&fields=key,title,author_name,isbn,language,cover_i,cover_edition_key&limit=100`;
    const res = await fetch(url);
    if (!res.ok) continue;
    const data = await res.json() as any;
    
    for (const doc of data.docs || []) {
      if (!doc.isbn || !doc.isbn.length) continue;
      
      for (const rawIsbn of doc.isbn) {
        const cleanIsbn = rawIsbn.replace(/[^0-9X]/gi, '').toUpperCase();
        if (cleanIsbn.length !== 10 && cleanIsbn.length !== 13) continue;
        if (seenIsbns.has(cleanIsbn)) continue;
        seenIsbns.add(cleanIsbn);
        
        let coverUrl = undefined;
        if (doc.cover_i) {
          coverUrl = `https://covers.openlibrary.org/b/id/${doc.cover_i}-M.jpg`;
        } else if (doc.cover_edition_key) {
          coverUrl = `https://covers.openlibrary.org/b/olid/${doc.cover_edition_key}-M.jpg`;
        }
        
        books.push({
          isbn: cleanIsbn,
          title: doc.title,
          author: doc.author_name ? doc.author_name[0] : query,
          coverUrl
        });
        break; // Only need 1 isbn per work
      }
      
      if (books.length >= 350) break;
    }
    if (books.length >= 350) break;
  }
  
  console.log(`Found ${books.length} books.`);
  
  let dartCode = `// GENERATED FILE - DO NOT EDIT MANUALLY
// Run scripts/seed/fetch_seed_books.ts to update

part of 'book_database_seed_service.dart';

final _seedBooks = [
`;
  
  for (const b of books) {
    const titleEscaped = b.title.replace(/[\n\r]+/g, " ").replace(/\\/g, "\\\\").replace(/\$/g, "\\$").replace(/'/g, "\\'");
    const authorEscaped = b.author.replace(/[\n\r]+/g, " ").replace(/\\/g, "\\\\").replace(/\$/g, "\\$").replace(/'/g, "\\'");
    const coverArg = b.coverUrl ? `coverUrl: '${b.coverUrl}'` : 'coverUrl: null';
    dartCode += `  (isbn: '${b.isbn}', title: '${titleEscaped}', author: '${authorEscaped}', ${coverArg}),\n`;
  }
  
  dartCode += `];\n`;
  
  writeFileSync("lib/services/books/book_database_seed_data.dart", dartCode);
  console.log("Wrote to lib/services/books/book_database_seed_data.dart");
}

fetchBooks().catch(console.error);
