//These are all SDFs shamelessly stolen from here:
//				https://iquilezles.org/articles/distfunctions/
//Thank you Inigo Quilez for your awesome work!!

float dot2( in vec3 v ) { return dot(v,v); }
float ndot( in vec3 a, in vec3 b ) { return a.x*b.x - a.y*b.y; }

const int sphere = 1;
float sdSphere( vec3 p, float s ){
  return length(p) - s;
}

const int box = 2;
float sdBox( vec3 p, vec3 b ){
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

const int boxFrame = 3;
float sdBoxFrame( vec3 p, vec3 b, float e ){
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

const int torus = 4;
float sdTorus( vec3 p, vec2 t ){
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

const int cappedTorus = 5;
float sdCappedTorus( vec3 p, vec2 sc, float ra, float rb){
  p.x = abs(p.x);
  float k = (sc.y*p.x>sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
  return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb;
}

const int cone = 6;
float sdCone( vec3 p, vec2 c, float h ){
  float q = length(p.xz);
  return max(dot(c.xy,vec2(q,p.y)),-h-p.y);
}

const int cylinder = 7;
float sdCylinder( vec3 p, vec3 c ){
  return length(p.xz-c.xy)-c.z;
}

const int plane = 8;
float sdPlane( vec3 p, vec3 n, float h ){
  // n must be normalized
  return dot(p,n) + h;
}

const int capsule = 9;
float sdCapsule( vec3 p, float h, float r ){
  p.y -= clamp( p.y, -h/2., h/2. );
  return length( p ) - r;
}

float madelbulb(vec3 p){
	vec3 w = p;
    float m = dot(w,w);

    vec4 trap = vec4(abs(w),m);
	float dz = 1.0;

	for( int i=0; i<4; i++ )
    {
        // trigonometric version (MUCH faster than polynomial)

        // dz = 8*z^7*dz
		dz = 8.0*pow(m,3.5)*dz + 1.0;

        // z = z^8+c
        float r = length(w);
        float b = 8.0*acos( w.y/r);
        float a = 8.0*atan( w.x, w.z );
        w = p + pow(r,8.0) * vec3( sin(b)*sin(a), cos(b), sin(b)*cos(a) );

        trap = min( trap, vec4(abs(w),m) );

        m = dot(w,w);
		if( m > 256.0 )
            break;
    }

    // distance estimation (through the Hubbard-Douady potential)
    return 0.25*log(m)*sqrt(m)/dz;
}