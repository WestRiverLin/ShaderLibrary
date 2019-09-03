using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//using SLua;
namespace SoFunny.UI {
    //[CustomLuaClassAttribute]
    public class UIEffectMask : MonoBehaviour {
        [SerializeField] RectTransform m_MaskRect;

        bool mask = true;
        public bool Mask {
            get { return mask; }
            set {
                if (mask != value) {
                    mask = value;
                    SetMask();
                }
            }
        }

        Vector3 m_CachePosition = Vector3.zero;

        Renderer[] m_Renderers;

        readonly Vector3[] m_WorldCorners = new Vector3[4];

        private void Awake() {
            m_Renderers = GetComponentsInChildren<Renderer>(true);

            m_MaskRect = m_MaskRect == null ? (transform as RectTransform) : m_MaskRect;

            m_CachePosition = m_MaskRect.position;

            SetMask();
        }

        private void LateUpdate() {
            if (m_MaskRect != null && (m_CachePosition != m_MaskRect.position)) {
                m_CachePosition = m_MaskRect.position;
                SetMask();
            }
        }

        [ContextMenu("SetMask")]
        public void SetMask() {
            if (m_Renderers != null) {
                var rect = transform as RectTransform;
                rect.GetWorldCorners(m_WorldCorners);
                var clipRect = new Vector4(m_WorldCorners[0].x, m_WorldCorners[0].y,
                                           m_WorldCorners[2].x, m_WorldCorners[2].y);
                for (int i = 0; i < m_Renderers.Length; i++) {
                    var mat = m_Renderers[i].material;
                    SetClipRect(mat, clipRect);
                }
            }
        }

        void SetClipRect(Material material, Vector4 clipRect) {
            material.SetVector("_ClipRect", clipRect);
            material.SetFloat("_UseClipRect", this.mask ? 1 : 0);
        }
    }
}


