/*
 * Original Windows comment:
 * "This code was created by Jeff Molofee 2000
 * A HUGE thanks to Fredric Echols for cleaning up
 * and optimizing the base code, making it more flexible!
 * If you've found this code useful, please let me know.
 * Visit my site at nehe.gamedev.net"
 * 
 * Cocoa port by Bryan Blackburn 2002; www.withay.com
 */

/* GLView.m */

#import "GLView.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "GLString.h"
#import "AppDelegate.h"

#define n	8


@interface GLView (InternalMethods)
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame;
- (BOOL) initGL;
@end


@implementation GLView

// Write text to screen
- (void) writeString: (NSString*) str textColor: (NSColor*) txt 
			boxColor: (NSColor*) box borderColor: (NSColor*) border
		  atLocation: (NSPoint) location withSize: (double) dsize 
		withFontName: (NSString*) fontName rotation:(float) rot
{
	// Init string and font
	NSFont* font = [ NSFont fontWithName:fontName size:dsize ];
	if (font == nil)
		return;
	
	GLString* text = [ [ GLString alloc ] initWithString:str withAttributes:[ NSDictionary dictionaryWithObjectsAndKeys:txt, NSForegroundColorAttributeName, font, NSFontAttributeName, nil ] withTextColor: txt withBoxColor: box withBorderColor: border ];
	
	// Get ready to draw
	int s = 0;
	glGetIntegerv (GL_MATRIX_MODE, &s);
	glMatrixMode (GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity ();
	glMatrixMode (GL_MODELVIEW);
	glPushMatrix();
	
	NSSize internalRes = [ self bounds ].size;
	// Draw
	glLoadIdentity();    // Reset the current modelview matrix
	glScaled(2.0 / internalRes.width, -2.0 / internalRes.height, 1.0);
	glTranslated(-internalRes.width / 2.0, -internalRes.height / 2.0, 0.0);
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);	// Make right color
	
	NSSize frameSize = [ text frameSize ];
	glTranslated(location.x + (frameSize.width / 2),
				 location.y + (frameSize.height / 2), 0);
	glRotated(rot, 0, 0, 1);
	glTranslated(-(location.x + (frameSize.width / 2)),
				 -(location.y + (frameSize.height / 2)), 0);
	
	[ text drawAtPoint:location ];
	
	// Reset things
	glPopMatrix(); // GL_MODELVIEW
	glMatrixMode (GL_PROJECTION);
    glPopMatrix();
    glMatrixMode (s);
}

- (void) applyFrameRate
{
	frames = frameCounter;
	frameCounter = 0;
}

- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits
		   depthBits:(int)numDepthBits fullscreen:(BOOL)runFullScreen
{
	NSOpenGLPixelFormat *pixelFormat;
	
	colorBits = numColorBits;
	depthBits = numDepthBits;
	pixelFormat = [ self createPixelFormat:frame ];
	if( pixelFormat != nil )
	{
		self = [ super initWithFrame:frame pixelFormat:pixelFormat ];
		if( self )
		{
			[ [ self openGLContext ] makeCurrentContext ];
			[ self reshape ];
			if( ![ self initGL ] )
			{
				[ self clearGLContext ];
				self = nil;
			}
			timer = [ NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(applyFrameRate) userInfo:nil repeats:YES ];
			
			game = (int*)malloc(n * n * sizeof(int));
			isTurn = EMPTY;
		}
	}
	else
		self = nil;
	
	return self;
}


/*
 * Create a pixel format and possible switch to full screen mode
 */
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame
{
	NSOpenGLPixelFormatAttribute pixelAttribs[ 16 ];
	int pixNum = 0;
	NSOpenGLPixelFormat *pixelFormat;
	
	pixelAttribs[ pixNum++ ] = NSOpenGLPFADoubleBuffer;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFAAccelerated;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFAColorSize;
	pixelAttribs[ pixNum++ ] = colorBits;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFADepthSize;
	pixelAttribs[ pixNum++ ] = depthBits;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFAMultisample;
	pixelAttribs[ pixNum++ ] = 1;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFASampleBuffers;
	pixelAttribs[ pixNum++ ] = 1;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFASamples;
	pixelAttribs[ pixNum++ ] = 8;
	
	pixelAttribs[ pixNum ] = 0;
	pixelFormat = [ [ NSOpenGLPixelFormat alloc ]
                   initWithAttributes:pixelAttribs ];
	
	return pixelFormat;
}

/*
 * Initial OpenGL setup
 */
- (BOOL) initGL
{ 
	glShadeModel( GL_SMOOTH );                // Enable smooth shading
	glClearColor( 0.0f, 0.0f, 0.0f, 0.5f );   // Black background
	glClearDepth( 1.0f );                     // Depth buffer setup
	glEnable( GL_DEPTH_TEST );                // Enable depth testing
	glDepthFunc( GL_LEQUAL );                 // Type of depth test to do
	// Really nice perspective calculations
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
	
	return TRUE;
}


/*
 * Resize ourself
 */
- (void) reshape
{ 
	NSRect sceneBounds;
	
	[ [ self openGLContext ] update ];
	sceneBounds = [ self bounds ];
	// Reset current viewport
	glViewport( 0, 0, sceneBounds.size.width, sceneBounds.size.height );
	glMatrixMode( GL_PROJECTION );   // Select the projection matrix
	glLoadIdentity();                // and reset it
	// Calculate the aspect ratio of the view
	glOrtho(0, sceneBounds.size.width, sceneBounds.size.height, 0, -1, 1);
	glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix
	glLoadIdentity();                // and reset it
}

int selPiece = -1;
- (void) mouseDown:(NSEvent*)event {
	if (isTurn == EMPTY)
		return;
	
	NSPoint p = [ event locationInWindow ];
	NSSize resolution = [ self bounds ].size;
	
	int x = p.x / (resolution.width / n);
	int y = n - (p.y / (resolution.height / n));
	
	if (x >= n || x < 0 || y < 0 || y >= n)
		return;
	
	if (selPiece != -1) {
		int x1 = selPiece % n;
		int y1 = selPiece / n;
		int moveLoc = y * n + x;
		if ((y1 == y + (game[selPiece] == RED ? -1 : 1)) && (x1 == x + 1 || x1 == x || x1 == x - 1)) {
			if (game[moveLoc] == EMPTY || (game[moveLoc] == !game[selPiece] && x1 != x)) {
				[ self makeMove:Move(x1, y1, x, y) ];
				selPiece = -1;
				
				return;
			}
		}
	}
	
	if (game[x + y * n] == isTurn) {
		selPiece = y * n + x;
		if (game[selPiece] == EMPTY)
			selPiece = -1;
	}

}

bool animating = false;
int animation = 0;
int animatingValue;
Move animationMove;

/*
 * Called when the system thinks we need to draw.
 */
- (void) drawRect:(NSRect)rect
{	
	// Clear the screen and depth buffer
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	
	glLoadIdentity();
	
	// Draw the background
	glClearColor(1, 0.893125, 0.665728, 1);
	
	NSSize resolution = [ self bounds ].size;
	
	// Draw the lines
	glLineWidth(2);
	glColor4d(0, 0, 0, 1);
	for (int y = 1; y < n; y++) {
		glBegin(GL_LINES);
		{
			glVertex2d(0, ((double)y / n) * resolution.height);
			glVertex2d(resolution.width, ((double)y / n) * resolution.height);
		}
		glEnd();
	}
	
	for (int x = 1; x < n; x++) {
		glBegin(GL_LINES);
		{
			glVertex2d(((double)x / n) * resolution.width, 0);
			glVertex2d(((double)x / n) * resolution.width, resolution.height);
		}
		glEnd();
	}
	
	// Draw the pieces
	for (int y = 0; y < n; y++) {
		for (int x = 0; x < n; x++) {
			if (game[x + y * n] == EMPTY)
				continue;
			
			// Draw a circle at this location
			if (selPiece == x + y * n) {
				glColor4d(0, 0, 0, 1);
				glBegin(GL_TRIANGLE_FAN);
				{
					double centerX = (x + 0.5) / n * resolution.width;
					double centerY = (y + 0.5) / n * resolution.height;
					glVertex2d(centerX, centerY);
					
					float radius = resolution.width / n * 0.4;
					for (float angle = 0; angle <= 360; angle += 360.0 / 36) {
						glVertex2d(centerX + cos(angle / 180 * M_PI) * radius,
								   centerY + sin(angle / 180 * M_PI) * radius);
					}
				}
				glEnd();
			}
			
			if (game[x + y * n] == RED)
				glColor4d(1, 0, 0, 1);
			else
				glColor4d(0.7, 0.65, 0.6, 1);
			
			// Draw a circle at this location
			glBegin(GL_TRIANGLE_FAN);
			{
				double centerX = (x + 0.5) / n * resolution.width;
				double centerY = (y + 0.5) / n * resolution.height;
				glVertex2d(centerX, centerY);
				
				float radius = resolution.width / n * 0.35;
				for (float angle = 0; angle <= 360; angle += 360.0 / 36) {
					glVertex2d(centerX + cos(angle / 180 * M_PI) * radius,
							 centerY + sin(angle / 180 * M_PI) * radius);
				}
			}
			glEnd();
		}
	}
	
	if (animating) {
		double x = animationMove.start_x +
			(animationMove.end_x - animationMove.start_x) * animation / 30.0;
		double y = animationMove.start_y +
			(animationMove.end_y - animationMove.start_y) * animation / 30.0;
		if (animatingValue == RED)
			glColor4d(1, 0, 0, 1);
		else
			glColor4d(0.7, 0.65, 0.6, 1);
		glBegin(GL_TRIANGLE_FAN);
		{
			double centerX = (x + 0.5) / n * resolution.width;
			double centerY = (y + 0.5) / n * resolution.height;
			glVertex2d(centerX, centerY);
			
			float radius = resolution.width / n * 0.35;
			for (float angle = 0; angle <= 360; angle += 360.0 / 36) {
				glVertex2d(centerX + cos(angle / 180 * M_PI) * radius,
						   centerY + sin(angle / 180 * M_PI) * radius);
			}
		}
		glEnd();
		
		if (++animation >= 30) {
			animation = 0;
			animating = false;
			
			Move m = animationMove;
			game[m.end_x + m.end_y * n] = animatingValue;
			
			[ del userMadeInput:game ];
		}
	}
	
	[ [ self openGLContext ] flushBuffer ];
	
	frameCounter++;
}

- (void) setGame:(int*)g {
	memcpy(game, g, n * n * sizeof(int));
	selPiece = -1;
	isTurn = EMPTY;
}

- (void) setIsTurn:(int)turn {
	isTurn = turn;
	selPiece = -1;
}

- (void) makeMove:(Move) m {
	animating = true;
	animation = 0;
	animationMove = m;
	animatingValue = game[m.start_x + m.start_y * n];
	game[m.start_x + m.start_y * n] = EMPTY;
	
	isTurn = EMPTY;
}

- (void) setAppDeletgate:(id)app {
	del = app;
}

/*
 * Cleanup
 */
- (void) dealloc
{
	if (game) {
		free(game);
		game = NULL;
	}
	if (timer)
	{
		[ timer invalidate ];
		timer = nil;
	}
}

@end
