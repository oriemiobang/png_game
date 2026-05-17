interface AppIconProps {
  size?: number;
  className?: string;
}

export function AppIcon({ size = 120, className = '' }: AppIconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 120 120"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
    >
      {/* Background Circle with Gradient */}
      <defs>
        <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" style={{ stopColor: '#667eea', stopOpacity: 1 }} />
          <stop offset="50%" style={{ stopColor: '#764ba2', stopOpacity: 1 }} />
          <stop offset="100%" style={{ stopColor: '#f093fb', stopOpacity: 1 }} />
        </linearGradient>
        
        <linearGradient id="cardGradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" style={{ stopColor: '#ffffff', stopOpacity: 0.95 }} />
          <stop offset="100%" style={{ stopColor: '#f8f9fa', stopOpacity: 0.95 }} />
        </linearGradient>

        <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
          <feDropShadow dx="0" dy="4" stdDeviation="8" floodOpacity="0.3" />
        </filter>

        <filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
          <feMerge>
            <feMergeNode in="coloredBlur"/>
            <feMergeNode in="SourceGraphic"/>
          </feMerge>
        </filter>
      </defs>

      {/* Main Background Circle */}
      <circle cx="60" cy="60" r="58" fill="url(#bgGradient)" />

      {/* Inner Shadow Circle */}
      <circle cx="60" cy="60" r="52" fill="none" stroke="rgba(255,255,255,0.2)" strokeWidth="1" />

      {/* Center Card/Display */}
      <g filter="url(#shadow)">
        {/* Main Display Card */}
        <rect x="25" y="35" width="70" height="50" rx="8" fill="url(#cardGradient)" />
        
        {/* Number Slots */}
        <g>
          {/* Slot 1 */}
          <rect x="30" y="50" width="14" height="20" rx="4" fill="#667eea" opacity="0.9" />
          <text x="37" y="65" fontFamily="Arial, sans-serif" fontSize="14" fontWeight="bold" fill="white" textAnchor="middle">
            ?
          </text>

          {/* Slot 2 */}
          <rect x="46" y="50" width="14" height="20" rx="4" fill="#764ba2" opacity="0.9" />
          <text x="53" y="65" fontFamily="Arial, sans-serif" fontSize="14" fontWeight="bold" fill="white" textAnchor="middle">
            ?
          </text>

          {/* Slot 3 */}
          <rect x="62" y="50" width="14" height="20" rx="4" fill="#d946ef" opacity="0.9" />
          <text x="69" y="65" fontFamily="Arial, sans-serif" fontSize="14" fontWeight="bold" fill="white" textAnchor="middle">
            ?
          </text>

          {/* Slot 4 */}
          <rect x="78" y="50" width="14" height="20" rx="4" fill="#f093fb" opacity="0.9" />
          <text x="85" y="65" fontFamily="Arial, sans-serif" fontSize="14" fontWeight="bold" fill="white" textAnchor="middle">
            ?
          </text>
        </g>

        {/* Decorative indicators below */}
        <g opacity="0.7">
          {/* P indicator */}
          <circle cx="40" y="80" r="3" fill="#10b981" />
          <text x="40" y="92" fontFamily="Arial, sans-serif" fontSize="8" fontWeight="bold" fill="white" textAnchor="middle">
            P
          </text>

          {/* N indicator */}
          <circle cx="60" y="80" r="3" fill="#f59e0b" />
          <text x="60" y="92" fontFamily="Arial, sans-serif" fontSize="8" fontWeight="bold" fill="white" textAnchor="middle">
            N
          </text>

          {/* Trophy */}
          <path 
            d="M 75 78 L 77 82 L 81 82 L 78 85 L 79 89 L 75 86 L 71 89 L 72 85 L 69 82 L 73 82 Z" 
            fill="#fbbf24" 
            filter="url(#glow)"
          />
        </g>
      </g>

      {/* Sparkle Effects */}
      <g opacity="0.8">
        {/* Top sparkle */}
        <circle cx="85" cy="25" r="2" fill="white" opacity="0.9" />
        <circle cx="85" cy="25" r="1" fill="white" />
        
        {/* Right sparkle */}
        <circle cx="95" cy="50" r="1.5" fill="white" opacity="0.8" />
        
        {/* Bottom sparkle */}
        <circle cx="30" cy="95" r="2" fill="white" opacity="0.9" />
        <circle cx="30" cy="95" r="1" fill="white" />
        
        {/* Left sparkle */}
        <circle cx="20" cy="40" r="1.5" fill="white" opacity="0.7" />
      </g>

      {/* Outer Ring Accent */}
      <circle 
        cx="60" 
        cy="60" 
        r="57" 
        fill="none" 
        stroke="rgba(255,255,255,0.3)" 
        strokeWidth="2"
        strokeDasharray="4 4"
      />
    </svg>
  );
}
