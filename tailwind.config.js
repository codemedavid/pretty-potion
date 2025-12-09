/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Soft Pink Modern Theme
        'theme-bg': '#fff7fb',        // Powder pink base
        'theme-text': '#2b1226',      // Deep plum text
        'theme-accent': '#f472b6',    // Vibrant pink
        'theme-secondary': '#f9a8d4', // Soft blush

        // Mapping standard colors to the new theme for compatibility
        primary: {
          50: '#fff7fb',
          100: '#ffeef6',
          200: '#fbd5e8',
          300: '#f9a8d4',
          400: '#f472b6',
          500: '#bf125d',
          600: '#9d174d',
          700: '#831843',
          800: '#6b0f38',
          900: '#2b1226',
        },
        // Deprecating gold but mapping to secondary/accent to prevent breaks
        gold: {
          50: '#fff7fb',
          100: '#ffe5ef',
          200: '#fcc9e0',
          300: '#f9a8d4',
          400: '#f472b6',
          500: '#ec4899',
          600: '#db2777',
          700: '#be185d',
          800: '#9d174d',
          900: '#2b1226',
        },
        accent: {
          light: '#fbcfe8',
          DEFAULT: '#f472b6',
          dark: '#db2777',
          white: '#ffffff',
          black: '#2b1226',
        },
      },
      fontFamily: {
        inter: ['Inter', 'sans-serif'],
      },
      boxShadow: {
        'soft': '0 2px 10px rgba(0, 0, 0, 0.03)',
        'medium': '0 4px 15px rgba(0, 0, 0, 0.05)',
        'hover': '0 8px 25px rgba(0, 0, 0, 0.08)',
      },
      animation: {
        'fadeIn': 'fadeIn 0.5s ease-out',
        'slideIn': 'slideIn 0.4s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0', transform: 'translateY(5px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideIn: {
          '0%': { opacity: '0', transform: 'translateX(-10px)' },
          '100%': { opacity: '1', transform: 'translateX(0)' },
        },
      },
    },
  },
  plugins: [],
}
