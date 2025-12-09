import React from 'react';
import { MessageCircle, Shield, Heart, HelpCircle } from 'lucide-react';
import { useCOAPageSetting } from '../hooks/useCOAPageSetting';

const Footer: React.FC = () => {
  const currentYear = new Date().getFullYear();
  const { coaPageEnabled } = useCOAPageSetting();

  // Contact Links
  const whatsappMessage = encodeURIComponent('Hi! I would like to inquire about your products.');
  const whatsappUrl = `https://wa.me/639357838505?text=${whatsappMessage}`;

  return (
    <footer className="bg-white border-t border-gray-100 pt-12 pb-6">
      <div className="container mx-auto px-4">
        <div className="flex flex-col md:flex-row items-center justify-between gap-8 mb-8">

          {/* Brand Section */}
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full overflow-hidden border border-gray-100">
              <img
                src="/logo.jpeg"
                alt="Pretty Potion"
                className="w-full h-full object-cover"
              />
            </div>
            <div className="text-left">
              <div className="font-bold text-theme-text text-lg tracking-tight">
                Pretty Potion
              </div>
              <div className="text-xs text-gray-500">Be fit • Stop your excuses</div>
            </div>
          </div>

          {/* Quick Links */}
          <div className="flex flex-wrap items-center gap-4 justify-center md:justify-end">
            {coaPageEnabled && (
              <a
                href="/coa"
                className="flex items-center gap-2 text-gray-600 hover:text-theme-accent transition-colors text-sm font-medium"
              >
                <Shield className="w-4 h-4" />
                <span>Lab Reports</span>
              </a>
            )}
            <a
              href={whatsappUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 text-gray-600 hover:text-theme-accent transition-colors text-sm font-medium"
            >
              <MessageCircle className="w-4 h-4" />
              <span>WhatsApp</span>
            </a>
          </div>

        </div>

        {/* Footer Bottom */}
        <div className="border-t border-gray-100 pt-6 text-center">
          <p className="text-xs text-gray-400 flex items-center justify-center gap-1">
            Made with
            <Heart className="w-3 h-3 text-theme-secondary fill-theme-secondary" />
            © {currentYear} Pretty Potion.
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
