(in-package :cl-user)

;; A stylistic ideosynchracy of C++ was passing result pointers into functions
;; to reduce the impact of the lack of garbage collection. It reduces consing
;; and allows functions to modify wrapped vectors and the like in place, so
;; it's laudable to keep around, but in general I've made such things an
;; optional final argument.

;; To-do list:
;; When i make foreign function calls in to glut, glu, or opengl, i should
;; do type checking to trap errors in lisp.

(defparameter *x-axis*     (make-array 3 :initial-contents '( 1.0  0.0  0.0)
                                       :element-type 'single-float))
(defparameter *y-axis*     (make-array 3 :initial-contents '( 0.0  1.0  0.0)
                                       :element-type 'single-float))
(defparameter *z-axis*     (make-array 3 :initial-contents '( 0.0  0.0  1.0)
                                       :element-type 'single-float))
(defparameter *neg-x-axis* (make-array 3 :initial-contents '(-1.0  0.0  0.0)
                                       :element-type 'single-float))
(defparameter *neg-y-axis* (make-array 3 :initial-contents '( 0.0 -1.0  0.0)
                                       :element-type 'single-float))
(defparameter *neg-z-axis* (make-array 3 :initial-contents '( 0.0  0.0 -1.0)
                                       :element-type 'single-float))
(defparameter *the-origin* (make-array 3 :initial-contents '( 0.0  0.0  0.0)
                                       :element-type 'single-float))

(defparameter *hel-white*   (make-array 4 :initial-contents '(1.0 1.0  1.0 1.0)
                                        :element-type 'single-float))
(defparameter *hel-grey*    (make-array 4 :initial-contents '(0.3 0.3  0.3 1.0)
                                        :element-type 'single-float))
(defparameter *hel-black*   (make-array 4 :initial-contents '(0.0 0.0  0.0 1.0)
                                        :element-type 'single-float))
(defparameter *hel-red*     (make-array 4 :initial-contents '(1.0 0.0  0.0 1.0)
                                        :element-type 'single-float))
(defparameter *hel-green*   (make-array 4 :initial-contents '(0.0 0.33 0.0 1.0)
                                        :element-type 'single-float))
(defparameter *hel-blue*    (make-array 4 :initial-contents '(0.0 0.0  1.0 1.0)
                                        :element-type 'single-float))
(defparameter *hel-yellow*  (make-array 4 :initial-contents '(1.0 1.0  0.0 1.0)
                                        :element-type 'single-float))
(defparameter *hel-cyan*    (make-array 4 :initial-contents '(0.0 1.0  1.0 1.0)
                                        :element-type 'single-float))
(defparameter *hel-magenta* (make-array 4 :initial-contents '(1.0 0.0  1.0 1.0)
                                        :element-type 'single-float))
(defparameter *hel-peach*   (make-array 4 :initial-contents '(1.0 0.3  0.2 1.0)
                                        :element-type 'single-float))
(defparameter *hel-pink*    (make-array 4 :initial-contents '(1.0 0.3  0.3 1.0)
                                        :element-type 'single-float))
(defparameter *hel-orange*  (make-array 4 :initial-contents '(1.0 0.3  0.0 1.0)
                                        :element-type 'single-float))

(defun radians (degrees)
  (/ (* 3.14159 degrees) 180.0))
(defun degrees (radians)
  (/ (* 180.0 radians) 3.14159))
(defun mag (p)
  (let ((p0 (elt p 0))
        (p1 (elt p 1))
        (p2 (elt p 2)))
    (+ (* p0 p0) (* p1 p1) (* p2 p2))))
(defun normalize (p)
  (let ((d 0.0))
    (dotimes (i 3) (incf d (expt (elt p i) 2)))
    (when (< 0.0 d)
      (setf d (sqrt d))
      (dotimes (i 3) (setf (elt p i) (/ (elt p i) d))))
    p))

(defun add-vectors (a b &optional result)
  (or result (setf result (make-array 3)))
  (dotimes (i 3)
    (setf (elt result i) (+ (elt a i) (elt b i))))
  result)
(defun scale-vector (a n &optional result)
  (or result (setf result (make-array 3)))
  (dotimes (i 3)
    (setf (elt result i) (* (elt a i) n)))
  result)
#+ignore ; overridden by lower defn anyway
(defun cross (a b c &optional norm)
  (or norm (setf norm (make-array 3)))
  (let ((a0 (elt a 0)) (a1 (elt a 1)) (a2 (elt a 2))
        (b0 (elt b 0)) (b1 (elt b 1)) (b2 (elt b 2))
        (c0 (elt c 0)) (c1 (elt c 1)) (c2 (elt c 2)))
    (setf (elt norm 0) (- (* (- b1 a1) (- c2 a2)) (* (- b2 a2) (- c1 a1)))
          (elt norm 1) (- (* (- b2 a2) (- c0 a0)) (* (- b0 a0) (- c2 a2)))
          (elt norm 2) (- (* (- b0 a0) (- c1 a1)) (* (- b1 a1) (- c0 a0)))))
  norm)
(defun cross (v1 v2 &optional crossproduct)
  (or crossproduct (setf crossproduct (make-array 3)))
  (setf (elt crossproduct 0) (- (* (elt v1 1) (elt v2 2))
                                (* (elt v1 2) (elt v2 1)))
        (elt crossproduct 1) (- (* (elt v1 2) (elt v2 0))
                                (* (elt v1 0) (elt v2 2)))
        (elt crossproduct 2) (- (* (elt v1 0) (elt v2 1))
                                (* (elt v1 1) (elt v2 0))))
  crossproduct)
(defun dot (v1 v2)
  (+ (* (elt v1 0) (elt v2 0))
     (* (elt v1 1) (elt v2 1))
     (* (elt v1 2) (elt v2 2))))


;; quaterion class (note that in my c++ code i use a type for this,
;; but since the quaternions aren't ever going to be in the C world
;; the lisp representation doesn't matter)
(defclass quaternion ()
  ((w :initform 1.0 :initarg :w :accessor w)
   (xyz :initform nil :initarg :xyz :accessor xyz))
  (:default-initargs :xyz (make-array 3 :initial-element 0.0)))
(defmethod addquats ((q1 quaternion) (q2 quaternion) &optional result)
  (or result (setf result (make-instance 'quaternion)))
  (setf (w result) (+ (w q1) (w q2)))
  (add-vectors (xyz q1) (xyz q2) (xyz result))
  result)
;; this computes q1*q2 not the other way around, so it does q2's rotation first
(defmethod mulquats ((q1 quaternion) (q2 quaternion) &optional result)
  (or result (setf result (make-instance 'quaternion)))
  (let ((t1 (make-array 3 :initial-element 0.0))
        (t2 (make-array 3 :initial-element 0.0))
        (t3 (make-array 3 :initial-element 0.0)))
    (scale-vector (xyz q1) (w q2) t1)
    (scale-vector (xyz q2) (w q1) t2)
    (cross (xyz q1) (xyz q2) t3)

    (setf (w result) (- (* (w q1) (w q2)) (dot (xyz q1) (xyz q2))))
    (add-vectors t1 t2 (xyz result))
    (add-vectors t3 (xyz result) (xyz result))
    result))

;; unit quaternions are made up of the axis of rotation (xyz) as a vector with
;; magnitude sin(theta/2) and a scalar (w) with magnitude cos(theta/2);
(defun axis-angle->quat (axis angle &optional q)
  (or q (setf q (make-instance 'quaternion)))
  (let ((theta (radians angle)))
    (setf (w q) (cos (/ theta 2.0)))
    (dotimes (i 3) (setf (elt (xyz q) i) (elt axis i)))
    (normalize (xyz q))
    (scale-vector (xyz q) (sin (/ theta 2.0)) (xyz q))
    q))
(defun quat->axis-angle (q &optional axis-angle) ; <- cons pair, bleah
  (or axis-angle (setf axis-angle (cons (make-array 3 :initial-element 0.0)
                                        0.0)))
  (let ((len (mag (xyz q))))
    (cond ((> len 0.0001)
           (setf (cdr axis-angle) (degrees (* 2.0 (acos (w q)))))
           (dotimes (i 3) (setf (elt (car axis-angle) i)
                                (/ (elt (xyz q) i) len))))
          (t ;; if len is near 0, angle of rotation is too, which can cause
             ;; trouble elsewhere, so just return zero
           (setf (cdr axis-angle) 0.0)
           (setf (elt (car axis-angle) 0) 0.0
                 (elt (car axis-angle) 1) 0.0
                 (elt (car axis-angle) 2) 1.0)))
    axis-angle))

;; this wraps a 9-number function with a point/point/vector function
;; note that this could REALLY stand to do some type checking...
(defun myLookAt (camera-position target-position upvector)
  (#_gluLookAt
   (coerce (elt camera-position 0) 'double-float)
   (coerce (elt camera-position 1) 'double-float)
   (coerce (elt camera-position 2) 'double-float)
   (coerce (elt target-position 0) 'double-float)
   (coerce (elt target-position 1) 'double-float)
   (coerce (elt target-position 2) 'double-float)
   (coerce (elt upvector 0) 'double-float)
   (coerce (elt upvector 1) 'double-float)
   (coerce (elt upvector 2) 'double-float)))
